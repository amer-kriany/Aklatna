# أكلاتنا — Aklatna App
## Project Context for AI Assistant

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## WHAT IS THIS APP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Aklatna (أكلاتنا) is a food ordering mobile app for the city of 
Daria (داريا), Syria. It lists all restaurants and juice bars in 
Daria, allows customers to browse menus and place orders, and 
connects them with the restaurant directly.

The app is being built by a single developer and will be used by 
real people in Daria. Code quality, error handling, and security 
are critical.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## CITY CONTEXT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
- Daria is a city near Damascus, part of western Ghouta
- The city has deep historical roots and strong local identity
- People speak Syrian Damascene dialect
- The city is rebuilding after years of hardship — this app is 
  part of that revival
- Local food culture: مشاوي, شاورما, فلافل, عصائر, مناقيش, 
  حلويات, أكل بيتي, سندويشات
- Famous for: العنب الداراني (Daranian grapes) — local fruit pride
- Currency: Syrian Pounds (ل.س)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## USER TYPES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Customer (this app) — browses restaurants, places orders
2. Restaurant Owner (separate web app — built later)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## CORE FEATURES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Browse restaurants and juice bars in Daria
2. View restaurant menu with photos and prices
3. Add items to cart and place orders
4. Choose: delivery OR self-pickup
5. Order notification goes to restaurant (via Supabase Realtime)
6. Customer phone number sent to restaurant with order
7. Browse job listings posted by restaurants
8. Contact restaurant for jobs via phone or WhatsApp

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## WHAT WE ARE NOT BUILDING (YET)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
- Delivery company integration (skipped for now)
- Payment gateway (cash only for now)
- In-app chat
- Reviews/ratings system (display only)
- Restaurant web dashboard (built separately later)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## SUPABASE TABLES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### profiles
| Column | Type | Notes |
|--------|------|-------|
| id | uuid | FK → auth.users |
| full_name | text | |
| phone | text | |
| role | text | 'customer' only in this app |
| created_at | timestamptz | |

### restaurants
| Column | Type | Notes |
|--------|------|-------|
| id | uuid | PK |
| name | text | |
| description | text | |
| logo_url | text | Supabase Storage |
| cover_url | text | Supabase Storage |
| category | text | 'restaurant' or 'juice_bar' |
| owner_id | uuid | FK → profiles |
| is_active | boolean | default true |
| is_open | boolean | default true |
| phone | text | shown on order status + jobs |
| rating | numeric | 0.0 - 5.0 |
| rating_count | integer | |
| created_at | timestamptz | |

### menu_categories
| Column | Type | Notes |
|--------|------|-------|
| id | uuid | PK |
| restaurant_id | uuid | FK → restaurants |
| name | text | |
| display_order | integer | |

### menu_items
| Column | Type | Notes |
|--------|------|-------|
| id | uuid | PK |
| restaurant_id | uuid | FK → restaurants |
| category_id | uuid | FK → menu_categories |
| name | text | |
| description | text | |
| price | numeric | in Syrian Pounds |
| image_url | text | optional |
| is_available | boolean | default true |

### orders
| Column | Type | Notes |
|--------|------|-------|
| id | uuid | PK |
| customer_id | uuid | FK → profiles |
| restaurant_id | uuid | FK → restaurants |
| status | text | 'pending', 'confirmed', 'preparing', 'ready', 'picked_up', 'cancelled' |
| type | text | 'delivery' or 'pickup' |
| total_price | numeric | |
| customer_phone | text | sent to restaurant |
| notes | text | optional customer notes |
| created_at | timestamptz | |

### order_items
| Column | Type | Notes |
|--------|------|-------|
| id | uuid | PK |
| order_id | uuid | FK → orders |
| menu_item_id | uuid | FK → menu_items |
| quantity | integer | |
| unit_price | numeric | price at time of order |
| notes | text | optional item notes |

### job_posts
| Column | Type | Notes |
|--------|------|-------|
| id | uuid | PK |
| restaurant_id | uuid | FK → restaurants |
| title | text | e.g. طباخ، كاشير |
| description | text | |
| requirements | text | |
| is_active | boolean | default true |
| created_at | timestamptz | |

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## RLS POLICIES SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
- profiles: user reads/updates own row only
- restaurants: all can read, owner can update
- menu_categories: all can read, owner can insert/update/delete
- menu_items: all can read, owner can insert/update/delete
- orders: customer sees own orders, authenticated insert only
- order_items: same as orders
- job_posts: all can read, owner can insert/update/delete

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## APP SCREENS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Onboarding (4 slides + auth entry)
2. Login
3. Register
4. Forgot Password (2 states)
5. Home (sections: trending, top rated, nearby, open now)
6. Search (3 states: default, results, no results)
7. Restaurant Detail / Menu (open + closed state)
8. Cart
9. Checkout
10. Order Success
11. Order Status / Tracking
12. My Orders
13. Jobs Page
14. Profile
15. Edit Profile
16. No Internet (full screen)
17. Empty States (no orders, no results, no internet)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## NAVIGATION STRUCTURE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Bottom Nav (main shell):
- الرئيسية → Home
- طلباتي → My Orders
- وظائف → Jobs
- حسابي → Profile

No bottom nav on:
- Auth screens (login, register, forgot password)
- Order success screen
- No internet screen
- Search screen

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## ORDER FLOW
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Customer browses → adds to cart → checkout → 
place order (INSERT to orders + order_items) →
Supabase Realtime notifies restaurant →
Restaurant updates status →
Customer sees status update in real time

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## TONE OF VOICE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
- Syrian Damascene dialect (not formal Arabic)
- Warm, local, friendly
- Examples:
  ✅ "شو بتحب تاكل اليوم؟"
  ✅ "تم استلام طلبك!"
  ✅ "ما لقينا نتائج"
  ❌ "لم يتم العثور على نتائج" (too formal)
