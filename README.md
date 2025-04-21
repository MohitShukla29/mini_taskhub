<div align="center"> <h1><font size="10">Mini TaskHub 📋</font></h1> <h3><font size="4">A simple yet elegant Flutter app for tracking your personal tasks. Built with Supabase Auth, GetX state management, and a responsive UI based on a Figma design.</font></h3> <br>
  </div>
✨ Key Features
🔐 Email/Password Authentication via Supabase

🧾 Add/Delete/Edit/Complete Tasks

🔁 Real-Time Updates

🎨 Responsive UI from a Figma Prototype

🌙 Light/Dark Mode Toggle

💾 Supabase Backend (Database + Auth)

⚙️ GetX for State Management & Routing

🛠️ Clean Folder Structure

🎥 Smooth Transitions & Animations

📝 Task Editing

🧑‍💻 Tech Stack
<div align="center"> <a href="https://flutter.dev/"><img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=flutter&logoColor=white"></a> <a href="https://supabase.com/"><img src="https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white"></a> <a href="https://dart.dev/"><img src="https://img.shields.io/badge/Dart-0175C2.svg?style=for-the-badge&logo=dart&logoColor=white"></a> <a href="https://getx.site/"><img src="https://img.shields.io/badge/GetX-7B1FA2?style=for-the-badge&logo=dart&logoColor=white"></a> </div>

📁 Folder Structure

lib/
│
├── auth/
│   ├── auth_service.dart             # Handles Supabase auth logic
│   ├── login_screen.dart             # Login UI
│   └── signup_screen.dart            # Signup UI
│
├── dashboard/
│   ├── add_task.dart                 # Bottom sheet/dialog to add tasks
│   ├── dashboard_screen.dart         # Main dashboard to show tasks
│   ├── edit_task.dart                # Optional: Edit task screen
│   ├── profile_screen.dart           # Optional: User profile/settings
│   ├── task_service.dart             # Handles Supabase task CRUD
│
├── models/
│   └── task_model.dart               # Task model class
│
├── main.dart                         # Entry point
├── placeholder_screen.dart           # Placeholder/temporary screen
├── splash_screen.dart                # Initial loading screen
├── theme_controller.dart             # App theming (light/dark mode)
│
└── test/
    └── widget_test.dart              # Basic test file

🚀 Getting Started

<br>

# 1. Clone the repository
git clone https://github.com/MohitShukla29/mini_taskhub

# 2. Navigate into the project
cd mini_taskhub

# 3. Navigate to the app directory (if exists)
cd app

# 4. Install Flutter dependencies
flutter pub get

# 5. Run the app
flutter run



🛠️ Supabase Setup
Follow these steps to set up Supabase for this project:

1️⃣ Create a Supabase Project
Go to https://supabase.com and create a new project.

Set a Project Name, Database Password, and Region.

Wait for the project to initialize.

2️⃣ Enable Authentication
Go to Authentication → Providers.

Enable Email/Password authentication.

3️⃣ Create the tasks Table
Navigate to Database → SQL Editor, and run the following SQL to create the tasks table:.
create table public.tasks (
  id uuid default uuid_generate_v4() primary key,
  title text not null,
  description text,
  due_date timestamp with time zone not null,
  team_member_ids text[] default '{}'::text[],
  progress numeric default 0,
  is_completed boolean default false,
  user_id uuid references auth.users(id) not null,
  created_at timestamp with time zone default now()
);
4️⃣ Get Supabase Keys
Go to Project Settings → API

Copy the following:

SUPABASE_URL

SUPABASE_ANON_KEY

5️⃣ Add to Your Project
Add these to your .env file (or directly into supabase_service.dart):


