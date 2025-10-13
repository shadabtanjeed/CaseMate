import uvicorn
from app.main import app

if __name__ == '__main__':
    # Use uvicorn programmatically for consistent startup in Windows
    uvicorn.run(app, host='127.0.0.1', port=8000, log_level='info')
