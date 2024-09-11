FROM python:3.10-slim

# Install dependencies
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY backend.py .

# Set environment variable for Gemini API key
ENV GEMINI_API_KEY=${GEMINI_API_KEY}
ENV FLASK_APP=backend.py

# Expose port for the application
EXPOSE 5000

# Start the application
CMD ["flask", "run", "-h", "0.0.0.0", "-p", "5000"]