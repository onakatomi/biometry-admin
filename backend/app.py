from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import ollama

app = FastAPI()

class QueryRequest(BaseModel):
    query: str

class QueryResponse(BaseModel):
    textResponse: str

@app.post("/generate", response_model=QueryResponse)
async def generate_response(request: QueryRequest):
    try:
        # Call the ollama model
        result = ollama.generate(model='gemma3', prompt=request.query)
        return QueryResponse(textResponse=result['response'])
    except Exception as e:
        # Raise HTTP 500 on errors
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app:app", host="0.0.0.0", port=3000, reload=True)

if True:
    print("hello world!")