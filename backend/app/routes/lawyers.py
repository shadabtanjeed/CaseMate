# lawyers.py

from fastapi import APIRouter, Query, HTTPException, Body
from typing import Optional
from datetime import datetime
from bson import ObjectId
from ..services.lawyer_service import lawyer_service
from ..schemas.user import UserResponse
from ..database import get_database  # Synchronous function

router = APIRouter()


@router.get("/lawyers")
async def list_lawyers(
    q: Optional[str] = Query(
        None, description="Search query for name or specialization"
    ),
    specialization: Optional[str] = Query(
        None, description="Exact specialization filter"
    ),
    min_rating: Optional[float] = Query(None, description="Minimum rating"),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
):
    lawyers = await lawyer_service.search_lawyers(
        q=q,
        specialization=specialization,
        min_rating=min_rating,
        page=page,
        page_size=page_size,
    )
    # Convert to response models
    result = []
    for l in lawyers:
        result.append(
            {
                "id": str(l.id),
                "name": l.full_name,
                "specialization": l.specialization,
                "rating": l.rating or 0.0,
                "reviews": l.total_cases or 0,
                "experience": l.years_of_experience or 0,
                "location": l.location or "",
                "fee": int(l.consultation_fee) if l.consultation_fee else 0,
                "image": None,
                "verified": l.is_verified,
                "bio": l.bio or "",
                "education": (
                    l.education.split(",")
                    if isinstance(l.education, str) and l.education
                    else (l.education or [])
                ),
                "achievements": (
                    l.achievements.split(",")
                    if isinstance(l.achievements, str) and l.achievements
                    else (l.achievements or [])
                ),
                "languages": [],
                "barAdmissions": [],
                "email": l.email or "",
            }
        )

    return {"data": result}


@router.get("/lawyers/specializations")
async def list_specializations():
    specs = await lawyer_service.get_unique_specializations()
    return {"data": specs}


@router.get("/lawyers/{lawyer_id}")
async def get_lawyer(lawyer_id: str):
    """Return a single lawyer by id (string of ObjectId).

    Normalizes fields to the frontend-friendly shape under the 'data' key.
    """
    l = await lawyer_service.get_lawyer_by_id(lawyer_id)
    if l is None:
        raise HTTPException(status_code=404, detail="Lawyer not found")

    result = {
        "id": str(l.id),
        "name": l.full_name,
        "specialization": l.specialization,
        "rating": l.rating or 0.0,
        "reviews": l.total_cases or 0,
        "experience": l.years_of_experience or 0,
        "location": l.location or "",
        "fee": int(l.consultation_fee) if l.consultation_fee else 0,
        "image": None,
        "verified": l.is_verified,
        "bio": l.bio or "",
        "education": (
            l.education.split(",")
            if isinstance(l.education, str) and l.education
            else (l.education or [])
        ),
        "achievements": (
            l.achievements.split(",")
            if isinstance(l.achievements, str) and l.achievements
            else (l.achievements or [])
        ),
        "languages": [],
        "barAdmissions": [],
        "email": l.email or "",
    }

    return {"data": result}


# ============================================
# CASE MANAGEMENT ENDPOINTS
# ============================================

def serialize_case(case_doc):
    """Convert MongoDB case document to JSON-serializable dict"""
    if case_doc is None:
        return None
    
    case_doc["_id"] = {"$oid": str(case_doc["_id"])}
    
    if "creation_date" in case_doc and isinstance(case_doc["creation_date"], datetime):
        case_doc["creation_date"] = {"$date": case_doc["creation_date"].isoformat()}
    
    if "last_updated" in case_doc and isinstance(case_doc["last_updated"], datetime):
        case_doc["last_updated"] = {"$date": case_doc["last_updated"].isoformat()}
    
    return case_doc


@router.get("/cases")
async def get_lawyer_cases(
    lawyer_email: str = Query(..., description="Email of the lawyer"),
    status: Optional[str] = Query(None, description="Filter by status: all, ongoing, pending, closed"),
    search: Optional[str] = Query(None, description="Search cases by title"),
):
    """Get all cases for a specific lawyer with optional filtering."""
    try:
        db = get_database()  # No await - it's synchronous!
        cases_collection = db["cases"]
        
        query = {"lawyer_email": lawyer_email}
        
        if status and status.lower() != 'all':
            query["status"] = status.lower()
        
        if search:
            query["case_title"] = {"$regex": search, "$options": "i"}
        
        # Use synchronous PyMongo - no await needed
        cases = list(cases_collection.find(query).sort("creation_date", -1))
        
        serialized_cases = [serialize_case(case) for case in cases]
        
        return {"data": serialized_cases}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching cases: {str(e)}")


@router.get("/cases/{case_id}")
async def get_case_details(case_id: str):
    """Get detailed information about a specific case."""
    try:
        db = get_database()  # No await - synchronous
        cases_collection = db["cases"]
        
        # Use synchronous find_one
        case = cases_collection.find_one({"_id": ObjectId(case_id)})
        
        if not case:
            raise HTTPException(status_code=404, detail="Case not found")
        
        return {"data": serialize_case(case)}
    
    except Exception as e:
        if "invalid ObjectId" in str(e).lower():
            raise HTTPException(status_code=400, detail="Invalid case ID format")
        raise HTTPException(status_code=500, detail=f"Error fetching case details: {str(e)}")


@router.put("/cases/{case_id}/status")
async def update_case_status(case_id: str, status_update: dict = Body(...)):
    """Update the status of a specific case."""
    try:
        new_status = status_update.get("status")
        
        valid_statuses = ["pending", "ongoing", "closed"]
        if not new_status or new_status.lower() not in valid_statuses:
            raise HTTPException(
                status_code=400, 
                detail=f"Invalid status. Must be one of: {', '.join(valid_statuses)}"
            )
        
        db = get_database()  # No await - synchronous
        cases_collection = db["cases"]
        
        # Use synchronous update_one
        result = cases_collection.update_one(
            {"_id": ObjectId(case_id)},
            {
                "$set": {
                    "status": new_status.lower(),
                    "last_updated": datetime.utcnow()
                }
            }
        )
        
        if result.matched_count == 0:
            raise HTTPException(status_code=404, detail="Case not found")
        
        if result.modified_count == 0:
            raise HTTPException(
                status_code=304, 
                detail="Case status was not modified (possibly already set to this status)"
            )
        
        # Use synchronous find_one
        updated_case = cases_collection.find_one({"_id": ObjectId(case_id)})
        
        return {"data": serialize_case(updated_case)}
    
    except HTTPException:
        raise
    except Exception as e:
        if "invalid ObjectId" in str(e).lower():
            raise HTTPException(status_code=400, detail="Invalid case ID format")
        raise HTTPException(status_code=500, detail=f"Error updating case status: {str(e)}")
    # Add these new endpoints at the end of lawyers.py, before the last closing bracket

@router.get("/clients")
async def get_lawyer_clients(
    lawyer_email: str = Query(..., description="Email of the lawyer"),
    status: Optional[str] = Query(None, description="Filter by status: all, active, past"),
):
    """Get all clients for a specific lawyer with their case information."""
    try:
        db = get_database()
        cases_collection = db["cases"]
        users_collection = db["users"]
        
        # Get all cases for this lawyer
        cases = list(cases_collection.find({"lawyer_email": lawyer_email}))
        
        # Group cases by user_email (client)
        from collections import defaultdict
        clients_data = defaultdict(lambda: {
            "user_email": "",
            "cases": [],
            "active_cases": 0,
            "completed_cases": 0,
            "total_cases": 0,
            "last_case_date": None,
        })
        
        for case in cases:
            user_email = case.get("user_email")
            if not user_email:
                continue
                
            case_status = case.get("status", "").lower()
            is_active = case_status in ["ongoing", "pending"]
            
            clients_data[user_email]["user_email"] = user_email
            clients_data[user_email]["cases"].append(case)
            clients_data[user_email]["total_cases"] += 1
            
            if is_active:
                clients_data[user_email]["active_cases"] += 1
            else:
                clients_data[user_email]["completed_cases"] += 1
            
            # Track most recent case date
            case_date = case.get("last_updated") or case.get("creation_date")
            if case_date:
                if not clients_data[user_email]["last_case_date"] or case_date > clients_data[user_email]["last_case_date"]:
                    clients_data[user_email]["last_case_date"] = case_date
        
        # Fetch user details for each client
        result = []
        for user_email, client_info in clients_data.items():
            user = users_collection.find_one({"email": user_email})
            
            if not user:
                continue
            
            # Determine if client is active or past
            is_active_client = client_info["active_cases"] > 0
            
            # Apply status filter
            if status and status.lower() != 'all':
                if status.lower() == 'active' and not is_active_client:
                    continue
                if status.lower() == 'past' and is_active_client:
                    continue
            
            # Get the most recent case for display
            recent_case = max(client_info["cases"], key=lambda c: c.get("last_updated") or c.get("creation_date"))
            
            client_data = {
                "user_email": user_email,
                "full_name": user.get("full_name", "Unknown"),
                "phone": user.get("phone"),
                "location": user.get("location"),
                "profile_image_url": user.get("profile_image_url"),
                "is_active": is_active_client,
                "active_cases": client_info["active_cases"],
                "completed_cases": client_info["completed_cases"],
                "total_cases": client_info["total_cases"],
                "recent_case_title": recent_case.get("case_title", ""),
                "recent_case_type": recent_case.get("case_type", ""),
                "recent_case_status": recent_case.get("status", ""),
                "last_case_date": client_info["last_case_date"].isoformat() if client_info["last_case_date"] else None,
            }
            
            result.append(client_data)
        
        # Sort by last case date (most recent first)
        result.sort(key=lambda x: x["last_case_date"] or "", reverse=True)
        
        return {"data": result}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching clients: {str(e)}")


@router.get("/clients/{user_email}/cases")
async def get_client_cases(
    user_email: str,
    lawyer_email: str = Query(..., description="Email of the lawyer"),
):
    """Get all cases for a specific client of this lawyer."""
    try:
        db = get_database()
        cases_collection = db["cases"]
        
        # Find all cases between this lawyer and client
        cases = list(cases_collection.find({
            "lawyer_email": lawyer_email,
            "user_email": user_email
        }).sort("creation_date", -1))
        
        serialized_cases = [serialize_case(case) for case in cases]
        
        return {"data": serialized_cases}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching client cases: {str(e)}")