# Build Vue.js frontend
FROM node:20-alpine AS build-stage

ARG VUE_APP_VERSION
ENV VUE_APP_VERSION=${VUE_APP_VERSION}

WORKDIR /app
COPY ./frontend/package*.json ./
RUN npm install --verbose
COPY ./frontend/ ./
RUN npm run build --verbose

# Setup Container and install Flask backend
FROM python:3.11-alpine AS deploy-stage

# Set environment variables
ENV PYTHONIOENCODING=UTF-8
ENV THEME=Default

WORKDIR /api
COPY ./backend/requirements.txt ./

# Install build dependencies and system libraries
RUN apk add --no-cache \
    gcc \
    g++ \
    libffi-dev \
    openssl-dev \
    musl-dev \
    postgresql-dev \
    mysql-dev \
    jpeg-dev \
    zlib-dev \
    yaml-dev \
    nginx \
    curl

# Install Docker Compose 2.x as a standalone binary
RUN curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

# Upgrade pip, setuptools, and wheel
RUN pip3 install --upgrade pip setuptools wheel

# Install Python packages from requirements.txt
RUN pip3 install -r requirements.txt --no-cache-dir --verbose

# Install SASS via gem
RUN apk add --no-cache ruby-dev && gem install sass --verbose && apk del ruby-dev

# Clean up build dependencies
RUN apk del gcc g++ libffi-dev musl-dev && \
    rm -rf /root/.cache /tmp/*

# Copy the backend code
COPY ./backend/ ./

# Expose ports and define the command to run the application
EXPOSE 5000
CMD ["python3", "app.py"]
