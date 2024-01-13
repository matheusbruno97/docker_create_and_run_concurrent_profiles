FROM ubuntu:22.04 AS base

# Install basic dependencies
RUN apt-get update && \
    apt-get install -y \
    xvfb \
    ca-certificates \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libatspi2.0-0 \
    libc6 \
    libcairo2 \
    libcups2 \
    libcurl4 \
    libdbus-1-3 \
    libdrm2 \
    libexpat1 \
    libgbm1 \
    libglib2.0-0 \
    libgtk-4-1 \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libu2f-udev \
    libvulkan1 \
    libx11-6 \
    libxcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxkbcommon0 \
    libxrandr2 \
    wget \
    xdg-utils \
    openjdk-18-jre-headless \
    curl \
    unzip \
    openssh-client \
    python3 \
    python3-pip \
    libayatana-appindicator3-dev && \
    curl --location --fail --output mlxdeb.deb "https://mlxdists.s3.eu-west-3.amazonaws.com/mlx/1.14.0/multiloginx-amd64.deb" && \
    dpkg -i mlxdeb.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y jq

# Create user and set working directory
WORKDIR /app
RUN useradd -m some-user && \
    chown -R some-user:some-user .

# Download and install mlx agent
FROM base AS copy-and-execute-script

# Copy main and automation scripts
RUN mkdir mlx-app && \
    cd mlx-app

COPY ./newrun.sh /app/mlx-app/newrun.sh

# Add permission to execute and run the main script
RUN chmod +x /app/mlx-app/newrun.sh
CMD bash /app/mlx-app/newrun.sh
