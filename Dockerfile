# ==========================================
# SECTION 1: Base Image
# ==========================================
# Start from Ubuntu 22.04 - a stable Linux operating system
FROM ubuntu:22.04

# ==========================================
# SECTION 2: Environment Setup
# ==========================================
# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# ==========================================
# SECTION 3: Install System Dependencies
# ==========================================
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    python3 \
    python3-pip \
    python3-dev \
    nginx \
    supervisor \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# ==========================================
# SECTION 4: Install Node.js
# ==========================================
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# ==========================================
# SECTION 5: Setup Working Directory
# ==========================================
WORKDIR /app

# ==========================================
# SECTION 6: Install PM2 Process Manager
# ==========================================
RUN npm install -g pm2

# ==========================================
# SECTION 7: Install Node.js Dependencies
# ==========================================
COPY backend/package*.json ./backend/
RUN cd backend && npm ci

# ==========================================
# SECTION 8: Install Python Dependencies
# ==========================================
COPY analytics_v2/requirements.txt ./analytics_v2/
RUN cd analytics_v2 && pip3 install --no-cache-dir -r requirements.txt

# ==========================================
# SECTION 9: Copy Application Code
# ==========================================
COPY backend/ ./backend/
COPY analytics_v2/ ./analytics_v2/
COPY nginx/ ./nginx/
COPY scripts/ ./scripts/

# ==========================================
# SECTION 10: Build TypeScript Backend
# ==========================================
RUN cd backend && npm run build

# ==========================================
# SECTION 11: Configure Nginx
# ==========================================
RUN rm /etc/nginx/sites-enabled/default
COPY nginx/nginx.conf /etc/nginx/sites-available/app
RUN ln -s /etc/nginx/sites-available/app /etc/nginx/sites-enabled/app

# ==========================================
# SECTION 12: Startup Script
# ==========================================
COPY scripts/start.sh ./
RUN chmod +x start.sh

# ==========================================
# SECTION 13: Security - Non-root User
# ==========================================
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Create PM2 directories with proper permissions
RUN mkdir -p /home/appuser/.pm2/logs /home/appuser/.pm2/pids /home/appuser/.pm2/modules
RUN chown -R appuser:appuser /home/appuser

RUN chown -R appuser:appuser /app
RUN chown -R appuser:appuser /var/log/nginx
RUN chown -R appuser:appuser /var/lib/nginx
RUN chown -R appuser:appuser /run

USER appuser

# ==========================================
# SECTION 14: Expose Port
# ==========================================
EXPOSE 10000

# ==========================================
# SECTION 15: Health Check
# ==========================================
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:10000/health || exit 1

# ==========================================
# SECTION 16: Start Command
# ==========================================
CMD ["./start.sh"]
