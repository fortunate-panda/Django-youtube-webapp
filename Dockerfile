# 1. Use an official, lightweight Python image
FROM python:3.11-slim-bookworm

# 2. Set environment variables for optimization
# PYTHONDONTWRITEBYTECODE: Prevents Python from writing .pyc files
# PYTHONUNBUFFERED: Ensures console output is not buffered by Docker
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# 3. Create a non-root user and group for security
RUN groupadd -r django_group && useradd -r -g django_group django_user

# 4. Set the working directory inside the container
WORKDIR /app

# 5. Install system dependencies required for Pillow (image/video processing)
# We clean up the apt cache immediately to keep the image size extremely small
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libjpeg-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# 6. Copy requirements and install them
COPY requirements.txt /app/
# We install gunicorn here directly to serve the app securely
RUN pip install -r requirements.txt gunicorn==21.2.0

# 7. Copy the rest of the application code
COPY . /app/

# 8. Create a media directory and change ownership of the app to the non-root user
RUN mkdir -p /app/media && chown -R django_user:django_group /app

# 9. Switch from the 'root' user to the secure 'django_user'
USER django_user

# 10. Expose the port Gunicorn will listen on
EXPOSE 8000

# 11. Define the command to run the app using Gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "3", "pytube_project.wsgi:application"]