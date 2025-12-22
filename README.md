# Swift Contest

**A comprehensive, real-time contest management platform built with Flutter and Supabase.**

---

## 🚀 About The Project

**Swift Contest** is a full-stack, cross-platform application designed to digitize and streamline the entire lifecycle of a contest. Born as an experimental university thesis project, it addresses the common challenges faced by organizers who rely on fragmented tools like spreadsheets, emails, and paper forms.

The application provides a centralized, secure, and intuitive platform for all stakeholders:

- **Organizers:** Can create and manage contests, invite participants and jurors, design custom voting forms, and generate results automatically.
- **Participants:** Can join contests, submit their work (including images and project files), and view final rankings.
- **Jurors:** Can vote in real-time through a structured and guided procedure, either as registered users or as anonymous "simple jurors" for live events.
- **Administrators:** Can supervise the platform, manage users, and moderate content through a dedicated internal dashboard.

## ✨ Key Features

- **Cross-Platform:** A single codebase built with **Flutter** targets both **Android** and **Web**, ensuring a consistent user experience.
- **Real-time Voting:** Leverages **Supabase Realtime** to provide a live and interactive voting experience.
- **Role-Based Access Control (RBAC):** A robust security model built on PostgreSQL's **Row Level Security (RLS)** and **RPC functions** ensures that users can only access the data they are authorized to see.
- **Flexible Jury System:** Supports both "appointed" juries (with registered users) and "simple" juries (for anonymous, token-based voting).
- **Customizable Voting Forms:** Organizers can create dynamic voting forms with different field types (sliders, text) and scopes (header, participant, footer).
- **Geo-restricted Voting:** Voting sessions can be restricted to a specific geographic area, verified using the device's location.
- **Secure File Management:** Handles uploads for contest images, participant works, and final rankings using **Supabase Storage**, with paths structured for security and organization.
- **Administrative Dashboard:** An internal tool built with **Retool** allows for secure, high-privilege operations like user management and content moderation.

## 🛠️ Tech Stack

The project is built on a modern, scalable, and largely open-source stack:

- **Frontend:**
  - **Framework:** [Flutter](https://flutter.dev/)
  - **Language:** [Dart](https://dart.dev/)
  - **State Management:** [flutter_bloc](https://bloclibrary.dev/)
  - **Navigation:** [auto_route](https://pub.dev/packages/auto_route)

- **Backend (BaaS):**
  - **Platform:** [Supabase](https://supabase.com/)
  - **Database:** [PostgreSQL](https://www.postgresql.org/)
  - **Authentication:** Supabase Auth (with OTP and anonymous sign-in)
  - **Real-time:** Supabase Realtime Subscriptions
  - **Storage:** Supabase Storage
  - **Serverless Functions:**
    - **RPC Functions:** [PL/pgSQL](https://www.postgresql.org/docs/current/plpgsql.html) for secure data access.
    - **Edge Functions:** [Deno](https://deno.com/) (TypeScript) for complex server-side logic.

- **Third-Party Services:**
  - **Email:** [Resend](https://resend.com/) for reliable SMTP delivery.
  - **Geocoding:** [Google Places API](https://developers.google.com/maps/documentation/places/web-service) for address autocomplete.
  - **Admin Panel:** [Retool](https://retool.com/) for the internal dashboard.

- **Development & Deployment:**
  - **Version Control:** [Git](https://git-scm.com/) & [GitHub](https://github.com/)
  - **IDE:** [IntelliJ IDEA](https://www.jetbrains.com/idea/)
  - **Web Hosting & CI/CD:** [Vercel](https://vercel.com/)
  - **Local Development:** [Supabase CLI](https://supabase.com/docs/guides/cli) & [Docker](https://www.docker.com/)

## 🏛️ Architecture Overview

The application follows a **Three-Tier Architecture** implemented with a **"Smart Client"** pattern:

1.  **Presentation Tier (Flutter Client):**
    - Handles all UI rendering and user interaction.
    - Contains client-side business logic, such as form validation and state management, to provide a responsive user experience.

2.  **Application Tier (Supabase Logic):**
    - The "brain" of the system, acting as the source of truth for business rules and security.
    - **RPC Functions** enforce fine-grained access control, ensuring that the client can only perform authorized actions.
    - **Edge Functions** orchestrate complex operations (e.g., user deletion) and act as secure proxies to external services.

3.  **Data Tier (Supabase Storage & DB):**
    - Consists of the **PostgreSQL** database for structured data and **Supabase Storage** for files.
    - The database is locked down by default using **Row Level Security (RLS)**, with all access mediated by the Application Tier.

## ⚙️ Local Development Setup

To run this project locally, you will need Flutter, Docker, and the Supabase CLI installed.

1.  **Clone the repository:**
    ```sh
    git clone https://github.com/TMoretta/Swift-Contest.git
    cd swift-contest
    ```

2.  **Set up Supabase environment variables:**
    - Edit `.env` file in the root of the project.
    - Add your Supabase project URL and `anon` key:
      ```env
      SUPABASE_URL=https://<your-project-ref>.supabase.co
      SUPABASE_ANON_KEY=<your-anon-key>
      ```

3.  **Start the local Supabase services:**
    This command will start the Docker containers for the database, storage, and other Supabase services.
    ```sh
    supabase start
    ```

4.  **Reset the local database and apply migrations/seed data:**
    This command will apply all migrations from the `supabase/migrations` folder and run the seed script from `supabase/seed.sql`.
    ```sh
    supabase db reset
    ```

5.  **Run the Flutter application:**
    ```sh
    flutter pub get
    flutter run
    ```

## 🔐 Edge Functions Secrets

You must set the following secrets in your Supabase project (under **Edge Functions > Secrets**) to enable full functionality:

- `GOOGLE_PLACES_API_KEY`: Required for the **Google Places API** to enable address autocomplete and location verification.
- `RESEND_API_KEY`: Used by **Resend** to send transactional emails (e.g., OTPs, invitations).
- `GITHUB_PAT`: A GitHub Personal Access Token used to fetch the latest APK release from the repository for in-app updates.
- `RETOOL_API_KEY`: A custom secret key used to authenticate requests coming from the **Retool** admin dashboard, ensuring that only authorized admin tools can invoke sensitive functions (like user deletion).

---

This project was developed as part of a university thesis. It is intended as a demonstration of software engineering principles and is not for production use.
