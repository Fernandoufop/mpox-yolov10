# ============================================================
# Dockerfile (ROS 2 + HOST-YOLOv10 lesion detection/staging)
# Target: Ubuntu 22.04 (ROS 2 Humble) by default
#
# Assumptions:
# - This repository is a ROS 2 workspace overlay copied into /root/ros2_ws/src
# - There is a requirements.txt inside the workspace (commonly at src/requirements.txt
#   or inside a package folder). This Dockerfile supports both paths.
#
# What this container does:
# 1) Installs ROS + build tooling + system libs commonly required by CV/Ultralytics
# 2) Runs rosdep to install ROS dependencies
# 3) Installs Python dependencies (Ultralytics, Torch, etc.) from requirements.txt
# 4) Builds the ROS 2 workspace with colcon
# 5) Provides a runtime image with the built workspace
#
# Notes:
# - If you need CUDA inside Docker, you must base on an NVIDIA CUDA image and
#   install ROS on top, or use an NVIDIA-enabled ROS image. This Dockerfile is CPU/GPU-agnostic.
# - For Ubuntu 24.04 and later, pip may require --break-system-packages.
# ============================================================

ARG ROS_DISTRO=humble

# ----------------------------
# Stage 1: dependencies
# ----------------------------
FROM ros:${ROS_DISTRO}-ros-core AS deps

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install system dependencies early for better caching
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    python3-pip \
    python3-rosdep \
    python3-colcon-common-extensions \
    python3-vcstool \
    lsb-release \
    ca-certificates \
    curl \
    # Common CV runtime deps (avoid OpenCV import errors)
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Create ros2_ws and copy files
WORKDIR /root/ros2_ws
COPY . /root/ros2_ws/src

# Initialize rosdep (safe for repeated builds)
RUN if [ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]; then \
      rosdep init; \
    fi && rosdep update --include-eol-distros

# Install ROS dependencies (from package.xml files)
RUN apt-get update && \
    rosdep install --from-paths src --ignore-src -r -y && \
    rm -rf /var/lib/apt/lists/*

# Install Python packages
# Supports either:
# - /root/ros2_ws/src/requirements.txt
# - /root/ros2_ws/src/<some_package>/requirements.txt
RUN set -e; \
    REQ=""; \
    if [ -f "/root/ros2_ws/src/requirements.txt" ]; then \
        REQ="/root/ros2_ws/src/requirements.txt"; \
    else \
        REQ="$(find /root/ros2_ws/src -maxdepth 2 -name requirements.txt | head -n 1)"; \
    fi; \
    if [ -z "${REQ}" ] || [ ! -f "${REQ}" ]; then \
        echo "ERROR: requirements.txt not found in /root/ros2_ws/src or its immediate subfolders."; \
        exit 1; \
    fi; \
    echo "Using requirements file: ${REQ}"; \
    UB_MAJOR="$(lsb_release -rs | cut -d. -f1)"; \
    if [ "${UB_MAJOR}" -ge 24 ]; then \
        pip3 install -r "${REQ}" --break-system-packages --ignore-installed; \
    else \
        pip3 install -r "${REQ}"; \
    fi

# ----------------------------
# Stage 2: build
# ----------------------------
FROM deps AS builder

SHELL ["/bin/bash", "-c"]

# Build the workspace
RUN source /opt/ros/${ROS_DISTRO}/setup.bash && \
    cd /root/ros2_ws && \
    colcon build --symlink-install

# ----------------------------
# Stage 3: runtime
# ----------------------------
FROM ros:${ROS_DISTRO}-ros-core AS runtime

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Runtime deps (keep minimal but sufficient for CV)
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-pip \
    lsb-release \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Copy built workspace from builder
WORKDIR /root/ros2_ws
COPY --from=builder /root/ros2_ws /root/ros2_ws

# Source overlay on container start
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc && \
    echo "source /root/ros2_ws/install/setup.bash" >> ~/.bashrc

# Default command
CMD ["bash"]
