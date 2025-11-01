<div align="center">
  <img width="400" alt="CaseMate Logo" src="https://github.com/user-attachments/assets/ef0a4065-45e7-4106-b6b2-bcf3a2ce91e6" />
</div>

<p></p>

CaseMate is a cross-platform legal assistant application composed of a Flutter frontend and a FastAPI backend. It provides features for users to chat with an AI legal assistant, discover and book consultations with lawyers, and for lawyers to manage clients, schedules, cases, and earnings.

---

## Features

- AI-powered legal chatbot (Groq/OpenAI OSS 70b)
- Lawyer discovery and search by specialization
- Book appointments and consultations with lawyers including video call
- Secure authentication and registration
- View and manage upcoming sessions
- Profile management

## Screenshots

### User Side

<table>
   <tr>
      <td align="center">
         <a href="https://github.com/user-attachments/assets/b8af59a9-d4a5-4aa8-8425-7f5e9b731dbd">
            <img src="https://github.com/user-attachments/assets/b8af59a9-d4a5-4aa8-8425-7f5e9b731dbd" alt="User Screen 1" width="300" style="border-radius:8px; box-shadow:0 4px 12px rgba(0,0,0,0.08);" />
         </a>
      </td>
      <td align="center">
         <a href="https://github.com/user-attachments/assets/f4310c31-0b85-4275-92c5-9aecc3e877d3">
            <img src="https://github.com/user-attachments/assets/f4310c31-0b85-4275-92c5-9aecc3e877d3" alt="User Screen 2" width="300" style="border-radius:8px; box-shadow:0 4px 12px rgba(0,0,0,0.08);" />
         </a>
      </td>
      <td align="center">
         <a href="https://github.com/user-attachments/assets/36fa777c-e783-4ea4-b9e7-96d55f412d12">
            <img src="https://github.com/user-attachments/assets/36fa777c-e783-4ea4-b9e7-96d55f412d12" alt="User Screen 3" width="300" style="border-radius:8px; box-shadow:0 4px 12px rgba(0,0,0,0.08);" />
         </a>
      </td>
   </tr>
   <tr>
      <td align="center">
         <a href="https://github.com/user-attachments/assets/70d5c9e3-d10c-4d5c-a551-6400312b61b2">
            <img src="https://github.com/user-attachments/assets/70d5c9e3-d10c-4d5c-a551-6400312b61b2" alt="User Screen 4" width="300" style="border-radius:8px; box-shadow:0 4px 12px rgba(0,0,0,0.08);" />
         </a>
      </td>
      <td></td>
      <td></td>
   </tr>
</table>

### Lawyer Side

<table>
   <tr>
      <td align="center">
         <a href="https://github.com/user-attachments/assets/4df1e6c3-ec3b-4b95-aa7e-6d357586ab8f">
            <img src="https://github.com/user-attachments/assets/4df1e6c3-ec3b-4b95-aa7e-6d357586ab8f" alt="Lawyer Screen 1" width="300" style="border-radius:8px; box-shadow:0 4px 12px rgba(0,0,0,0.08);" />
         </a>
      </td>
      <td align="center">
         <a href="https://github.com/user-attachments/assets/e21501af-5bfb-4c90-9dfd-312ae4ad0eb7">
            <img src="https://github.com/user-attachments/assets/e21501af-5bfb-4c90-9dfd-312ae4ad0eb7" alt="Lawyer Screen 2" width="300" style="border-radius:8px; box-shadow:0 4px 12px rgba(0,0,0,0.08);" />
         </a>
      </td>
      <td align="center">
         <a href="https://github.com/user-attachments/assets/961c09ad-f100-435c-a1f2-a7d08fa5ae6a">
            <img src="https://github.com/user-attachments/assets/961c09ad-f100-435c-a1f2-a7d08fa5ae6a" alt="Lawyer Screen 3" width="300" style="border-radius:8px; box-shadow:0 4px 12px rgba(0,0,0,0.08);" />
         </a>
      </td>
   </tr>
   <tr>
      <td align="center">
         <a href="https://github.com/user-attachments/assets/957059f2-a5b9-4b60-a3c2-0cbcd080ced2">
            <img src="https://github.com/user-attachments/assets/957059f2-a5b9-4b60-a3c2-0cbcd080ced2" alt="Lawyer Screen 4" width="300" style="border-radius:8px; box-shadow:0 4px 12px rgba(0,0,0,0.08);" />
         </a>
      </td>
      <td align="center">
         <a href="https://github.com/user-attachments/assets/49998dde-da8f-4ae1-8540-120e3175b57c">
            <img src="https://github.com/user-attachments/assets/49998dde-da8f-4ae1-8540-120e3175b57c" alt="Lawyer Screen 5" width="300" style="border-radius:8px; box-shadow:0 4px 12px rgba(0,0,0,0.08);" />
         </a>
      </td>
      <td></td>
   </tr>
</table>

---

## Requirements

- Python 3.11 (recommended) for backend
- Flutter SDK for frontend (see `frontend/pubspec.yaml`)
- MongoDB instance
- Groq API key (for AI chatbot)
- SSLCommerz API credentials
- Gmail account for email notifications

---

## Getting Started

### Clone the repository

```bash
git clone https://github.com/shadabtanjeed/casemate.git
```

### Backend Setup

1. **Create a Python 3.11 virtual environment**
   ```bash
   cd backend
   python3.11 -m venv casemate_venv
   source casemate_venv/bin/activate  # Linux/macOS
   # casemate_venv\Scripts\activate.ps1 # Windows
   ```
2. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```
3. **Configure environment variables**

   - Create a `.env` file in the `backend` directory and fill in your secrets:

   ```env
   MONGODB_URL=your-mongodb-connection-string
   DATABASE_NAME=casemate_db
   SECRET_KEY=your-secret-key-change-this-in-production-min-32-chars
   ALGORITHM=HS256
   ACCESS_TOKEN_EXPIRE_MINUTES=30
   REFRESH_TOKEN_EXPIRE_DAYS=7

   # Email configuration (for future use)
   SMTP_HOST=smtp.gmail.com
   SMTP_PORT=587
   EMAIL_SENDER=your-email@gmail.com
   EMAIL_PASSWORD=your-email-password
   EMAIL_SENDER_NAME=CaseMate Support

   groq_api_key=your-groq-api-key
   ```

4. **Run the backend server**

```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
# or
python run_uvicorn.py
```

5. **Verify health endpoint**
   ```bash
   curl http://127.0.0.1:8000/health
   ```

### Frontend Setup (Flutter)

1. **Install Flutter**: [Flutter Install Guide](https://flutter.dev/docs/get-started/install)
2. **Install dependencies**
   ```bash
   cd frontend
   flutter pub get
   ```
3. **Configure environment variables**

   - Create a `.env` file in the `frontend` directory and add your backend URL and other necessary keys:

   ```env
   SERVER_URL=your_server_url
   # SERVER_URL=http://10.0.2.2:8000 # for Android emulator

   # SSLCommerz Configuration
   SSLCOMMERZ_STORE_ID=your-sslcommerz-store-id
   SSLCOMMERZ_STORE_PASSWORD=your-sslcommerz-store-password

   ```

4. **Run the app**

```bash
flutter run
```

---

## Project Structure

```
CaseMate/
├── backend/      # FastAPI backend
├── frontend/     # Flutter frontend
└── ...           # Docs, configs, assets
```

---

## How to navigate

### Account Creation

- Users can create an account by selecting the appropriate role — **General User** or **Lawyer** — during registration.

### Lawyer Schedule Setup

- To set up a schedule, **log in** as a **Lawyer**.
- Navigate to **Schedule → Availability**.
- Configure your available dates and times as needed.

### Booking an Appointment (User)

- To book an appointment, **log in** as a **General User**.
- Go to the **Lawyer List**, select **View Profile**, and open the **Availability** section.
- Choose a suitable time slot and confirm your booking.

### Joining a Video Session

- **For Lawyers:**
  - Go to **Schedule**, select the desired date from the calendar, and click **Start** to begin the session.
- **For Users:**
  - Navigate to **Sessions → Upcoming Sessions**, then click **Join Session** to enter the meeting.

## Notes

This application is currently in **prototype phase**. While the frontend and backend infrastructure are fully functional, some features and UI components may not be fully implemented or may require additional development. Users should expect ongoing refinements and feature enhancements.

---
