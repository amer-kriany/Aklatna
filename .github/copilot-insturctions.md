🤖 GitHub Copilot Instructions (Gemini Model)

You are assisting in a Flutter project called Aklatna (أكلاتنا), a food ordering app for Daria, Syria.

Your role is a senior Flutter engineer following Clean Architecture strictly.

🧱 TECH STACK (DO NOT CHANGE)
Flutter (latest stable)
State Management: flutter_bloc (BLoC + Cubit)
Backend: Supabase ONLY
Dependency Injection: GetIt + injectable
Navigation: GoRouter
Error handling: dartz (Either<Failure, Success>)
Equatable for state comparison
cached_network_image for images
connectivity_plus for network checks

No other frameworks or backends allowed.

📁 ARCHITECTURE RULES

Use Clean Architecture:

feature/
├── data/ (Supabase + models)
├── domain/ (entities + usecases)
└── presentation/ (bloc/cubit + UI)

Rules:

Business logic ONLY in usecases
Supabase calls ONLY in datasources
Repositories only handle mapping + errors
UI must NEVER contain business logic
⚙️ CODING RULES
Always use Either<Failure, Success>
Never throw raw exceptions to UI
Use BLoC for complex logic, Cubit for simple UI state
All states must include: Initial, Loading, Success, Failure
All entities must be immutable
All states/events must extend Equatable
Use explicit types (no var for class fields)
🧠 SUPABASE RULES
Supabase is the ONLY backend
Use Supabase Auth only
RLS MUST be enabled on all tables
Never bypass RLS
Use Supabase Realtime for orders
Use Supabase Storage for images
Store tokens in flutter_secure_storage
Handle all Supabase errors → convert to Failure

Tables:
profiles, restaurants, menu_categories, menu_items, orders, order_items, job_posts

🔌 DATA FLOW RULE

Datasource → throws exceptions
Repository → converts to Failure
UseCase → returns Either<Failure, Success>
BLoC → emits UI states

Never skip a layer.

🎨 UI RULES
App is Arabic-first (Syrian dialect)
Full RTL support required
Currency: Syrian Pound (ل.س)
Colors:
Primary: #ED3D2F
Secondary: #F0F0F0
Neutral: #87726D
Rounded UI (16px radius)
Minimal shadows, prefer borders
Always show:
loading states
error states (Arabic messages)
empty states (icon + text + action)
🚨 FORBIDDEN
No Supabase calls inside UI or BLoC
No business logic inside widgets
No multiple features in one file
No print() debugging
No hardcoded strings in UI
No SharedPreferences for sensitive data
No skipping error handling
No ignoring RLS
🧭 BEHAVIOR
Generate production-ready Flutter code
Follow Clean Architecture strictly
Prefer simple, scalable solutions
If something breaks architecture → fix it instead of ignoring
Keep code consistent with existing structure
⚡ OUTPUT STYLE
Write clean, minimal, readable code
Avoid overengineering
No unnecessary explanations unless asked
Focus on correctness and structure