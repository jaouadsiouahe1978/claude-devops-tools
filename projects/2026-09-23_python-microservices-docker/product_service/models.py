from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class ProductCreate(BaseModel):
    name: str
    price: float
    description: Optional[str] = None

class ProductUpdate(BaseModel):
    name: Optional[str] = None
    price: Optional[float] = None
    description: Optional[str] = None

class Product(BaseModel):
    id: int
    name: str
    price: float
    description: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True
