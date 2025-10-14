# CaseMate

CaseMate is a cross-platform legal assistant application composed of a Flutter frontend and a FastAPI backend. It provides features for users to chat with an AI legal assistant, discover and book consultations with lawyers, and for lawyers to manage clients, schedules, cases, and earnings.

---

## Features

- FastAPI backend exposing REST endpoints for authentication and app APIs
- Flutter frontend (multi-platform) with discovery, booking, chat, and lawyer management
- Simple authentication flow and example services for email and auth

## Repository layout

Top-level (important folders)

```
/backend               # FastAPI backend (Python)
/frontend              # Flutter app (Dart/Flutter)
/readme.md             # This file
```

Inside backend (high level)

```
backend/
  app/                 # FastAPI app package
  run_uvicorn.py       # helper script to start uvicorn
  run_and_test.py      # starts server & sends a test request
  requirements.txt     # Python dependencies (if present)
  .venv*/              # local virtualenvs (should not be committed)
```

Inside frontend (high level)

```
frontend/
  lib/                 # Flutter source code
  pubspec.yaml
```

## Requirements

- Linux / macOS / Windows
- Python 3.11 (recommended) for the backend
- Flutter SDK for the frontend (matching the app's channel/version in `frontend/pubspec.yaml`)
- Git

## Backend — FastAPI (Python)

This section shows recommended steps to create a Python 3.11 environment and run the backend. The repo contains helper scripts, but these steps are platform-agnostic.

### Create a Python 3.11 virtual environment

1. Make sure Python 3.11 is installed and available as `python3.11`.

Check the version:

```bash
python3.11 --version
which python3.11
```

2. If you need to install Python 3.11 on Debian/Ubuntu:

```bash
sudo apt update
sudo apt install -y python3.11 python3.11-venv python3.11-dev build-essential libssl-dev libffi-dev
```

3. Create a new venv in the `backend` folder and activate it:

```bash
cd /home/shadab/github_repos/CaseMate/backend
python3.11 -m venv casemate_venv
source casemate_venv/bin/activate
```

### Install dependencies

With the venv activated:

```bash
pip install -r requirements.txt
```

### Run the backend

Option A — run with uvicorn (development, reload enabled):

```bash
uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload
```

Option B — helper python script (already included in the repo):

```bash
python run_uvicorn.py
# or
python run_and_test.py  # launches server in thread and sends a sample register request
```

Verify the server health endpoint:

```bash
curl http://127.0.0.1:8000/health
```

## Frontend — Flutter

1. Install Flutter: https://flutter.dev/docs/get-started/install
2. Ensure `flutter` is in your PATH and run:

```bash
cd /home/shadab/github_repos/CaseMate/frontend
flutter pub get
flutter run
```

Select the target device/emulator as usual with Flutter.

## Environment / Configuration

Create a .env file in the `backend`.

```
MONGODB_URL=your_mongodb_connection_string
DATABASE_NAME=your_database_name
SECRET_KEY=your_secret_key
```
