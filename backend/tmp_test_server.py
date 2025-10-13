import threading, time, requests
from app.main import app
import uvicorn

def run_server():
    uvicorn.run(app, host='127.0.0.1', port=8000)

thr = threading.Thread(target=run_server, daemon=True)
thr.start()
# Wait a bit for server startup
for i in range(10):
    try:
        r = requests.get('http://127.0.0.1:8000/health', timeout=1)
        print('health:', r.status_code, r.text)
        break
    except Exception as e:
        print('waiting for server...', e)
        time.sleep(0.5)

# Send register request
payload = {
    'email': 'testuser3@example.com',
    'password': 'Password1',
    'full_name': 'Test User 3',
    'role': 'user'
}
try:
    r = requests.post('http://127.0.0.1:8000/api/auth/register', json=payload, timeout=5)
    print('status', r.status_code)
    print('body', r.text)
except Exception as e:
    print('request failed', e)

# Allow some time for logs
time.sleep(1)
