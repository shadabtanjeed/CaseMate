from fastapi import APIRouter, Query
from typing import Optional
from ..services.lawyer_service import lawyer_service
from ..schemas.user import UserResponse

router = APIRouter()


@router.get("/lawyers")
async def list_lawyers(
    q: Optional[str] = Query(None, description="Search query for name or specialization"),
    specialization: Optional[str] = Query(None, description="Exact specialization filter"),
    min_rating: Optional[float] = Query(None, description="Minimum rating"),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
):
    lawyers = await lawyer_service.search_lawyers(
        q=q, specialization=specialization, min_rating=min_rating, page=page, page_size=page_size
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
                "fee": 0,
                "image": None,
                "verified": l.is_verified,
                "bio": l.bio or "",
                "education": l.education.split(',') if isinstance(l.education, str) and l.education else (l.education or []),
                "achievements": l.achievements.split(',') if isinstance(l.achievements, str) and l.achievements else (l.achievements or []),
                "languages": [],
                "barAdmissions": [],
            }
        )

    return {"data": result}


@router.get("/lawyers/{lawyer_id}")
async def get_lawyer(lawyer_id: str):
    """Return a single lawyer by id (string of ObjectId).

    Normalizes fields to the frontend-friendly shape under the 'data' key.
    """
    l = await lawyer_service.get_lawyer_by_id(lawyer_id)
    if l is None:
        from fastapi import HTTPException

        raise HTTPException(status_code=404, detail="Lawyer not found")

    result = {
        "id": str(l.id),
        "name": l.full_name,
        "specialization": l.specialization,
        "rating": l.rating or 0.0,
        "reviews": l.total_cases or 0,
        "experience": l.years_of_experience or 0,
        "location": l.location or "",
        "fee": 0,
        "image": None,
        "verified": l.is_verified,
        "bio": l.bio or "",
        "education": l.education.split(',') if isinstance(l.education, str) and l.education else (l.education or []),
        "achievements": l.achievements.split(',') if isinstance(l.achievements, str) and l.achievements else (l.achievements or []),
        "languages": [],
        "barAdmissions": [],
    }

    return {"data": result}
