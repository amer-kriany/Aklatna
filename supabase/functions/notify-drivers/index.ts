/// <reference lib="deno.ns" />

import { createClient } from "@supabase/supabase-js";
const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const supabaseServiceRoleKey =
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const firebaseServiceAccount =
  Deno.env.get("FIREBASE_SERVICE_ACCOUNT")!;

const supabase = createClient(
  supabaseUrl,
  supabaseServiceRoleKey,
);

interface Order {
  id: number;
  business_id: string;
  business_name: string | null;
  order_number: string | null;
}

interface Driver {
  id: string;
  fcm_token: string | null;
}

interface ServiceAccount {
  project_id: string;
  private_key: string;
  client_email: string;
}

function base64UrlEncode(data: Uint8Array): string {
  let binary = "";

  for (const byte of data) {
    binary += String.fromCharCode(byte);
  }

  return btoa(binary)
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/, "");
}

function pemToArrayBuffer(pem: string): ArrayBuffer {
  const base64 = pem
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replace(/\s/g, "");

  const binary = atob(base64);
  const bytes = new Uint8Array(binary.length);

  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }

  return bytes.buffer;
}

async function createFirebaseAccessToken(
  serviceAccount: ServiceAccount,
): Promise<string> {
  const now = Math.floor(Date.now() / 1000);

  const header = base64UrlEncode(
    new TextEncoder().encode(
      JSON.stringify({
        alg: "RS256",
        typ: "JWT",
      }),
    ),
  );

  const payload = base64UrlEncode(
    new TextEncoder().encode(
      JSON.stringify({
        iss: serviceAccount.client_email,
        scope:
          "https://www.googleapis.com/auth/firebase.messaging",
        aud: "https://oauth2.googleapis.com/token",
        iat: now,
        exp: now + 3600,
      }),
    ),
  );

  const unsignedToken = `${header}.${payload}`;

  const keyData = pemToArrayBuffer(
    serviceAccount.private_key,
  );

  const privateKey = await crypto.subtle.importKey(
    "pkcs8",
    keyData,
    {
      name: "RSASSA-PKCS1-v1_5",
      hash: "SHA-256",
    },
    false,
    ["sign"],
  );

  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    privateKey,
    new TextEncoder().encode(unsignedToken),
  );

  const jwt = `${unsignedToken}.${base64UrlEncode(
    new Uint8Array(signature),
  )}`;

  const response = await fetch(
    "https://oauth2.googleapis.com/token",
    {
      method: "POST",
      headers: {
        "Content-Type":
          "application/x-www-form-urlencoded",
      },
      body: new URLSearchParams({
        grant_type:
          "urn:ietf:params:oauth:grant-type:jwt-bearer",
        assertion: jwt,
      }),
    },
  );

  if (!response.ok) {
    const error = await response.text();

    throw new Error(
      `Failed to get Firebase access token: ${error}`,
    );
  }

  const data = await response.json();

  return data.access_token;
}

Deno.serve(async (req: Request) => {
  try {
    if (req.method !== "POST") {
      return new Response(
        JSON.stringify({
          error: "Method not allowed",
        }),
        {
          status: 405,
          headers: {
            "Content-Type": "application/json",
          },
        },
      );
    }

    const body = await req.json();

    const order: Order = body.record;

    if (!order) {
      return new Response(
        JSON.stringify({
          error: "No order record received",
        }),
        {
          status: 400,
          headers: {
            "Content-Type": "application/json",
          },
        },
      );
    }

    console.log(
      `🔔 New order received: ${order.order_number}`,
    );

    // ========================================================
    // 1. GET ALL DRIVERS WITH FCM TOKENS
    // ========================================================

    const {
      data: drivers,
      error: driversError,
    } = await supabase
      .from("profiles")
      .select("id, fcm_token")
      .eq("role", "driver")
      .not("fcm_token", "is", null);

    if (driversError) {
      throw driversError;
    }

    const typedDrivers: Driver[] =
      (drivers ?? []) as Driver[];

    if (typedDrivers.length === 0) {
      console.log(
        "⚠️ No drivers with FCM tokens",
      );

      return new Response(
        JSON.stringify({
          success: true,
          message: "No drivers available",
        }),
        {
          status: 200,
          headers: {
            "Content-Type": "application/json",
          },
        },
      );
    }

    // ========================================================
    // 2. GET DRIVERS WITH ONGOING ORDERS
    // ========================================================

    const {
      data: ongoingOrders,
      error: ongoingError,
    } = await supabase
      .from("order")
      .select("driver_id")
      .not("driver_id", "is", null)
      .in("order_status", [
        "pending",
        "preparing",
        "ready",
        "out_for_delivery",
      ]);

    if (ongoingError) {
      throw ongoingError;
    }

    const busyDriverIds = new Set<string>(
      (ongoingOrders ?? [])
        .map(
          (order: { driver_id: string | null }) =>
            order.driver_id,
        )
        .filter((id: string | null): id is string => id !== null)
    );

    // ========================================================
    // 3. ONLY AVAILABLE DRIVERS
    // ========================================================

    const availableDrivers = typedDrivers.filter(
      (driver: Driver) =>
        !busyDriverIds.has(driver.id),
    );

    if (availableDrivers.length === 0) {
      console.log(
        "⚠️ All drivers currently have an ongoing order",
      );

      return new Response(
        JSON.stringify({
          success: true,
          message: "No available drivers",
        }),
        {
          status: 200,
          headers: {
            "Content-Type": "application/json",
          },
        },
      );
    }

    const tokens = availableDrivers
      .map(
        (driver: Driver) => driver.fcm_token,
      )
      .filter(
        (token): token is string =>
          typeof token === "string" &&
          token.length > 0,
      );

    if (tokens.length === 0) {
      return new Response(
        JSON.stringify({
          success: true,
          message: "No valid FCM tokens",
        }),
        {
          status: 200,
          headers: {
            "Content-Type": "application/json",
          },
        },
      );
    }

    // ========================================================
    // 4. FIREBASE AUTHENTICATION
    // ========================================================

    const serviceAccount: ServiceAccount =
      JSON.parse(firebaseServiceAccount);

    const accessToken =
      await createFirebaseAccessToken(
        serviceAccount,
      );

    // ========================================================
    // 5. SEND NOTIFICATION
    // ========================================================

    const title = "طلب جديد متاح";

    const notificationBody =
      `يوجد طلب جديد من مطعم ${order.business_name ?? "غير معروف"} — اضغط لعرض التفاصيل.`;

    let successCount = 0;
    let failureCount = 0;

    for (const token of tokens) {
      try {
        const response = await fetch(
          `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
          {
            method: "POST",
            headers: {
              Authorization:
                `Bearer ${accessToken}`,
              "Content-Type":
                "application/json",
            },
            body: JSON.stringify({
              message: {
                token,

                notification: {
                  title,
                  body: notificationBody,
                },

                data: {
                  type: "new_order",
                  order_id: String(order.id),
                  order_number:
                    order.order_number ?? "",
                },

                android: {
                  priority: "high",

                  notification: {
                    channel_id: "orders",
                    sound: "default",
                  },
                },
              },
            }),
          },
        );

        if (response.ok) {
          successCount++;
        } else {
          failureCount++;

          const error =
            await response.text();

          console.error(
            `❌ FCM failed: ${error}`,
          );
        }
      } catch (error) {
        failureCount++;

        console.error(
          "❌ Failed sending notification:",
          error,
        );
      }
    }

    console.log(
      `✅ Notifications sent: ${successCount}, failed: ${failureCount}`,
    );

    return new Response(
      JSON.stringify({
        success: true,
        notified: successCount,
        failed: failureCount,
      }),
      {
        status: 200,
        headers: {
          "Content-Type": "application/json",
        },
      },
    );
  } catch (error) {
    console.error(
      "❌ notify-drivers error:",
      error,
    );

    return new Response(
      JSON.stringify({
        success: false,
        error:
          error instanceof Error
            ? error.message
            : String(error),
      }),
      {
        status: 500,
        headers: {
          "Content-Type": "application/json",
        },
      },
    );
  }
});