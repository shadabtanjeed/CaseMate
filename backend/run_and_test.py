import threading
import time
import requests
import uvicorn
from app.main import app
import uuid
import time


def run_server():
    # run uvicorn in this process (logs printed to stdout)
    uvicorn.run(app, host='127.0.0.1', port=8000)


thr = threading.Thread(target=run_server, daemon=True)
thr.start()

# wait for server to be ready
for i in range(20):
    try:
        r = requests.get('http://127.0.0.1:8000/health', timeout=1)
        print('health', r.status_code, r.text)
        break
    except Exception as e:
        print('waiting...', e)
        time.sleep(0.5)
else:
    print('server did not start')

# send register with a short password
unique_email = f"test_{int(time.time())}_{uuid.uuid4().hex[:6]}@example.com"
payload = {
    'email': unique_email,
    'password': 'abc123',
    'full_name': 'Short Pass',
    'role': 'user'
}
try:
    r = requests.post('http://127.0.0.1:8000/api/auth/register', json=payload, timeout=10)
    print('status', r.status_code)
    print('body', r.text)
except Exception as e:
    print('request failed', e)

# allow some time for server logs to print
time.sleep(1)
print('done')
