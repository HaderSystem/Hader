# 📚 Hader – Smart Attendance System

> **Hader** is an intelligent attendance system that uses **QR code scanning** and **face recognition** to ensure secure, fraud-proof attendance tracking for university students.

---

## 🎯 Project Objective

To digitize and secure the attendance process in educational institutions using biometric verification and real-time session validation through scheduled lectures.

---

## 🚀 Key Features

- ✅ Student check-in via **dynamic QR code**
- ✅ Identity verification using **Face Recognition API**
- ✅ Role-based dashboards:
  - 👨‍🎓 Student
  - 👨‍🏫 Teacher
  - 👮‍♂️ Security
  - 👩‍💼 Admin
- ✅ Course and lecture scheduling (date, time, days of the week)
- ✅ Attendance tracking and history display
- ✅ Multi-language support (Arabic 🇸🇦 / English 🇬🇧)
- ✅ Light/Dark mode toggle
- ✅ Face image uploads to Supabase Storage
- ✅ Supabase Row Level Security (RLS) policies for data protection

---

## 🛠️ Tech Stack

| Area         | Tools/Technologies                        |
|--------------|-------------------------------------------|
| Frontend     | Flutter, Dart, Easy Localization          |
| Backend      | Node.js (Express.js)                      |
| Auth & DB    | Supabase (PostgreSQL, Auth, Storage)      |
| Face API     | Face++ (Third-party API integration)      |
| QR Code      | `qr_flutter`, `mobile_scanner` packages   |
| Hosting      | Render (for Node.js server deployment)    |

---

## 📸 Screenshots

| Student View | Teacher View | Admin View |
|--------------|--------------|------------|
| ![student](screenshots/student_home.png) | ![teacher](screenshots/teacher_dashboard.png) | ![admin](screenshots/admin_manage.png) |

---

## 🧑‍💻 How to Run

### Prerequisites
- Flutter SDK installed
- Supabase project set up (with proper tables and policies)
- Node.js installed (for the backend API)

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/your-username/hader.git
cd hader

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
