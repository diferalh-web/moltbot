FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Create data directory for Chroma
RUN mkdir -p /app/data/chroma /app/flows

ENV PYTHONPATH=/app
ENV CHROMA_PERSIST_DIR=/app/data/chroma
ENV FLOWS_DIR=/app/flows

EXPOSE 8000

CMD ["python", "main.py"]
