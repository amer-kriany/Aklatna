# أكلاتنا (Aklatna)

A production food-ordering app connecting customers with local restaurants and juice shops in **Daria, Syria**. Built solo, end-to-end, over ~2.5 months — from schema design to release.

📲 **Download:** https://amer-kriany.github.io/Aklatna_Download/

---

## Overview

Aklatna lets customers browse restaurants and juice shops in Daria, order food for delivery or pickup, and track order status in real time. Restaurants manage their menus and incoming orders through a companion web dashboard (built by [Mohammad], sharing the same backend). A dedicated driver flow handles delivery claiming and live tracking.

This repo contains the **customer + driver Flutter app**.

## Tech Stack

- **Flutter** (Dart) — cross-platform mobile client
- **BLoC** — state management, fully migrated (no Cubit/Riverpod remnants)
- **Clean Architecture** — `datasource → repository → usecase → BLoC → page`
- **GetIt** — dependency injection
- **go_router** — declarative navigation
- **Supabase** — PostgreSQL, Auth, Row Level Security, Realtime, Edge Functions, pg_cron
- **OpenStreetMap** — driver location & tracking (via `latlong2`)
- **Firebase Cloud Messaging** — infrastructure in place (Edge Function → FCM pipeline)

## Key Features

- 🏠 Browse restaurants & juice shops — trending, promotions, open-now filtering
- 🍔 Menus with photos, categories, and live availability
- 🛒 Cart & checkout — delivery or pickup, with an active-order guard preventing duplicate concurrent orders
- 📡 Real-time order status tracking via Supabase Realtime (no push-notification dependency for core status updates)
- 🚗 Full driver flow — role-based routing, order claiming, OpenStreetMap live tracking, no un-claim once accepted
- 💼 Restaurant-posted job listings, moderated via an approval flag
- ⭐ Promotions engine with time-windowed discounts
- 🔐 Phone-OTP customer auth; separate admin-provisioned auth for restaurant accounts

## Architecture Notes

- **No code reviewer on this project** — every RLS policy is manually tested against real customer/restaurant JWTs (never admin credentials) before shipping.
- **`SECURITY DEFINER` discipline**: trigger functions must declare `SECURITY DEFINER` *inside* the `CREATE FUNCTION` body — an `ALTER FUNCTION` afterward isn't sufficient, since dashboard-side function recreation silently resets it to `SECURITY INVOKER`.
- **Single source of truth for order state**: an `OrderStatusX` enum extension centralizes "is this order ongoing" logic, after early duplication caused silent bugs.
- **Automation via `pg_cron`**: stale pending orders are auto-cancelled, and cron's own log table is pruned nightly to avoid bloating the free-tier database.
- **Shared-schema coordination**: the restaurant dashboard and this app share one Postgres schema. Any change to shared tables — including silent semantic changes to existing columns — requires explicit sign-off from the dashboard maintainer before shipping.

## Status

Soft-launched in Daria. Actively maintained — see [Issues](../../issues) for known gaps and planned work (scheduled orders, distance/ETA on cards, password reset).

## Author

Built by **Amer Kriany** — Flutter developer.
🔗 [LinkedIn](https://linkedin.com/in/amer-kriany-1020b9365) · ✉️ amer.kriany0@gmail.com

Restaurant dashboard: **Mohammad**

## License

This is a proprietary production application. Source is shared here for portfolio purposes only — please reach out before reusing any part of it commercially.
