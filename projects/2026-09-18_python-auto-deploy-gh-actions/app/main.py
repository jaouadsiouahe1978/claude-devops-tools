"""
Application Python - Exemple de CI/CD Pipeline
Simple API REST avec FastAPI
"""
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from utils import greet, calculate_sum, validate_email

app = FastAPI(title="Python App", version="1.0.0")


class Item(BaseModel):
    name: str
    value: int


class EmailRequest(BaseModel):
    email: str


@app.get("/")
def read_root():
    """Endpoint racine - health check"""
    return {
        "status": "ok",
        "message": "Application running successfully!",
        "version": "1.0.0"
    }


@app.get("/health")
def health_check():
    """Health check endpoint"""
    return {"status": "healthy"}


@app.get("/greet/{name}")
def greet_user(name: str):
    """Greeter endpoint"""
    return {"message": greet(name)}


@app.post("/calculate")
def calculate(numbers: list[int]):
    """Calculate sum of numbers"""
    if not numbers:
        raise HTTPException(status_code=400, detail="Numbers list cannot be empty")
    result = calculate_sum(numbers)
    return {
        "numbers": numbers,
        "sum": result,
        "average": result / len(numbers)
    }


@app.post("/validate-email")
def check_email(request: EmailRequest):
    """Validate email format"""
    is_valid = validate_email(request.email)
    return {
        "email": request.email,
        "valid": is_valid
    }


@app.get("/info")
def app_info():
    """Return application info"""
    return {
        "name": "Python CI/CD App",
        "version": "1.0.0",
        "description": "Démonstration d'un pipeline CI/CD complet",
        "endpoints": [
            "GET /",
            "GET /health",
            "GET /greet/{name}",
            "POST /calculate",
            "POST /validate-email",
            "GET /info"
        ]
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
