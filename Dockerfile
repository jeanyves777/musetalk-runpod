# MuseTalk Production Dockerfile for RunPod Serverless
# High-quality real-time avatar video generation

FROM runpod/pytorch:2.1.0-py3.10-cuda11.8.0-devel-ubuntu22.04

# Set working directory
WORKDIR /workspace

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    ffmpeg \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Clone MuseTalk repository
RUN git clone https://github.com/TMElyralab/MuseTalk.git /workspace/MuseTalk

WORKDIR /workspace/MuseTalk

# Install Python dependencies
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir runpod boto3 requests huggingface_hub

# Download model weights from HuggingFace
RUN python3 -c "from huggingface_hub import snapshot_download; \
    snapshot_download(repo_id='TMElyralab/MuseTalk', local_dir='./models/musetalk', local_dir_use_symlinks=False)" || \
    echo "Model download will happen at runtime"

# Copy handler
COPY handler.py /workspace/MuseTalk/handler.py

# Set Python path
ENV PYTHONPATH="/workspace/MuseTalk:${PYTHONPATH}"

# Run handler
CMD ["python", "-u", "/workspace/MuseTalk/handler.py"]
