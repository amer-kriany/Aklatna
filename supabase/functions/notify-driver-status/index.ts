import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

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
  order_number: string | null;
  business_name: string | null;
  order_status: string;
  driver_id: string | null;
}

interface Profile {
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
    const oldOrder: Order | null =
      body.old_record ?? null;

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

    // ========================================================
    // 1. ONLY HANDLE PREPARING / READY
    // ========================================================

    if (
      order.order_status !== "preparing" &&
      order.order_status !== "ready"
    ) {
      return new Response(
        JSON.stringify({
          success: true,
          message: "Status does not require notification",
        }),
        {
          status: 200,
          headers: {
            "Content-Type": "application/json",
          },
        },
      );
    }

    // Don't notify if the status didn't actually change.
    if (
      oldOrder &&
      oldOrder.order_status === order.order_status
    ) {
      return new Response(
        JSON.stringify({
          success: true,
          message: "Status did not change",
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
    // 2. MAKE SURE ORDER HAS A DRIVER
    // ========================================================

    if (!order.driver_id) {
      console.log(
        `⚠️ Order ${order.order_number} has no assigned driver`,
      );

      return new Response(
        JSON.stringify({
          success: true,
          message: "No assigned driver",
        }),
        {
          status: 200,
          headers: {
            "Content-Type": "application/json",
          },
        },
      );
    }

    console.log(
      `🔔 Order ${order.order_number} changed to ${order.order_status}`,
    );

    console.log(
      `🛵 Assigned driver: ${order.driver_id}`,
    );

    // ========================================================
    // 3. GET THAT DRIVER'S FCM TOKEN
    // ========================================================

    const {
      data: driver,
      error: driverError,
    } = await supabase
      .from("profiles")
      .select("id, fcm_token")
      .eq("id", order.driver_id)
      .eq("role", "driver")
      .maybeSingle();

    if (driverError) {
      throw driverError;
    }

    if (!driver) {
      return new Response(
        JSON.stringify({
          success: false,
          error: "Assigned driver not found",
        }),
        {
          status: 404,
          headers: {
            "Content-Type": "application/json",
          },
        },
      );
    }

    const typedDriver = driver as Profile;

    if (
      !typedDriver.fcm_token ||
      typedDriver.fcm_token.length === 0
    ) {
      console.log(
        `⚠️ Driver ${order.driver_id} has no FCM token`,
      );

      return new Response(
        JSON.stringify({
          success: true,
          message: "Driver has no FCM token",
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
    // 5. CREATE NOTIFICATION
    // ========================================================

    let title: string;
    let notificationBody: string;

    if (order.order_status === "preparing") {
      title = "الطلب قيد التحضير";
      notificationBody =
        `المطعم بدأ بتحضير الطلب ${order.order_number ?? ""}`;
    } else {
      title = "الطلب جاهز";
      notificationBody =
        `الطلب ${order.order_number ?? ""} جاهز للاستلام`;
    }

    // ========================================================
    // 6. SEND TO ONLY THE ASSIGNED DRIVER
    // ========================================================

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
            token: typedDriver.fcm_token,

            notification: {
              title,
              body: notificationBody,
            },

            data: {
              type: "order_status",
              order_id: String(order.id),
              order_number:
                order.order_number ?? "",
              status: order.order_status,
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

    if (!response.ok) {
      const error = await response.text();

      console.error(
        `❌ FCM failed: ${error}`,
      );

      return new Response(
        JSON.stringify({
          success: false,
          error,
        }),
        {
          status: 500,
          headers: {
            "Content-Type": "application/json",
          },
        },
      );
    }

    console.log(
      `✅ Notification sent to driver ${order.driver_id}`,
    );

    return new Response(
      JSON.stringify({
        success: true,
        notified: 1,
        driver_id: order.driver_id,
        status: order.order_status,
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
      "❌ notify-driver-status error:",
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
