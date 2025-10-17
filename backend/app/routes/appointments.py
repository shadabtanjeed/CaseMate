from fastapi import APIRouter, Depends
from typing import List
from ..services.appointment_service import appointment_service
from ..utils.dependencies import get_current_user_email

router = APIRouter()


@router.get("/appointments/me")
async def get_my_appointments(current_user_email: str = Depends(get_current_user_email)):
    """Return appointments for the current user (both upcoming and past)."""
    appts = await appointment_service.get_appointments_for_user(current_user_email)
    # Normalize fields for frontend
    result = []
    
    def _to_epoch_ms(val):
        """Convert various DB date formats to integer milliseconds since epoch.
        Handles datetime, numeric, string, and mongo extended json like
        {'$date': {'$numberLong': '1761091200000'}} or {'$date': 1761091200000}.
        """
        if val is None:
            return None
        # datetime objects
        try:
            from datetime import datetime

            if isinstance(val, datetime):
                return int(val.timestamp() * 1000)
        except Exception:
            pass

        # If date is a string containing JSON (exported extended JSON), try to parse it
        if isinstance(val, str) and val.strip().startswith('{'):
            try:
                import json

                parsed = json.loads(val)
                return _to_epoch_ms(parsed)
            except Exception:
                pass

        # Mongo extended json dict
        if isinstance(val, dict):
            # {'$date': {'$numberLong': '...'}}
            if '$date' in val:
                d = val['$date']
                if isinstance(d, dict) and '$numberLong' in d:
                    try:
                        return int(d['$numberLong'])
                    except Exception:
                        return None
                # sometimes $date directly contains number
                try:
                    return int(d)
                except Exception:
                    return None
            # sometimes date stored as {'$numberLong': '...'}
            if '$numberLong' in val:
                try:
                    return int(val['$numberLong'])
                except Exception:
                    return None

        # numeric types
        try:
            if isinstance(val, (int, float)):
                return int(val)
        except Exception:
            pass

        # string numeric
        if isinstance(val, str):
            try:
                return int(val)
            except Exception:
                try:
                    return int(float(val))
                except Exception:
                    return None

        return None

    # Batch fetch lawyer details for all appointments to avoid N+1 queries
    emails = [a.get("lawyer_email") for a in appts if a.get("lawyer_email")]
    lawyer_map = {}
    if emails:
        try:
            from ..database import get_database

            db = get_database()

            def _fetch_lawyers():
                cursor = db['lawyers'].find({'email': {'$in': emails}}, {'full_name': 1, 'phone': 1, 'email': 1})
                return list(cursor)

            lawyers = await __import__('asyncio').to_thread(_fetch_lawyers)
            for l in lawyers:
                try:
                    email = l.get('email')
                    lawyer_map[email] = {
                        'lawyer_name': l.get('full_name') or '',
                        'lawyer_phone': l.get('phone') or '',
                    }
                except Exception:
                    continue
        except Exception:
            # If enrichment fails, continue without lawyer details
            import logging

            logging.exception('Error fetching lawyer details for appointments')

    for a in appts:
        date_ms = _to_epoch_ms(a.get("date"))
        created_ms = _to_epoch_ms(a.get("created_at"))
        is_finished_raw = a.get("is_finished", False)
        is_finished = bool(is_finished_raw) if not isinstance(is_finished_raw, str) else (is_finished_raw.lower() == 'true' or is_finished_raw == '1')

        base = {
            "appointment_id": a.get("appointment_id"),
            "lawyer_email": a.get("lawyer_email"),
            "user_email": a.get("user_email"),
            "date": date_ms,
            "start_time": a.get("start_time"),
            "end_time": a.get("end_time"),
            "is_finished": is_finished,
            "case_type": a.get("case_type"),
            "description": a.get("description"),
            "consultation_type": a.get("consultation_type"),
            "created_at": created_ms,
        }

        # merge lawyer enrichment if available
        le = lawyer_map.get(a.get('lawyer_email'))
        if le:
            base.update(le)

        result.append(base)

    return {"data": result}
