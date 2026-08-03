
## SUPABASE TABLES


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

## RLS POLICIES SUMMARY
- profiles: user reads/updates own row only
- restaurants: all can read, owner can update
- menu_categories: all can read, owner can insert/update/delete
- menu_items: all can read, owner can insert/update/delete
- orders: customer sees own orders, authenticated insert only
- order_items: same as orders
- job_posts: all can read, owner can insert/update/delete

