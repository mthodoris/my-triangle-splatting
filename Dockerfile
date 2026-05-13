FROM nvidia/cuda:11.8.0-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=${CUDA_HOME}/bin:${PATH}
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}
ENV MAX_JOBS=2
ENV CMAKE_BUILD_PARALLEL_LEVEL=2
ENV TORCH_CUDA_ARCH_LIST="7.0;7.5;8.0;8.6;8.9;9.0"

RUN apt-get update && apt-get install -y --no-install-recommends \
    git wget curl ca-certificates \
    build-essential cmake ninja-build \
    python3.10 python3.10-venv python3.10-dev python3-pip \
    libgl1 libglib2.0-0 libxrender1 libxext6 libsm6 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN git clone --recursive https://github.com/trianglesplatting/triangle-splatting.git

WORKDIR /app/triangle-splatting

RUN python3.10 -m venv /opt/venv
ENV PATH="/opt/venv/bin:${PATH}"

RUN pip install --upgrade pip setuptools wheel

RUN pip install \
    torch==2.4.0 \
    torchvision==0.19.0 \
    torchaudio==2.4.0 \
    --index-url https://download.pytorch.org/whl/cu118

# PyTorch3D
RUN pip install --no-build-isolation \
    "git+https://github.com/facebookresearch/pytorch3d.git"

RUN pip install \
    numpy \
    scipy \
    tqdm \
    plyfile \
    imageio \
    opencv-python \
    matplotlib \
    scikit-image \
    lpips \
    trimesh \
    mediapy \
    tensorboard \
    einops \
    jaxtyping \
    rich \
    ninja
RUN git submodule update --init --recursive

RUN which python3 && python3 -c "import torch; print(torch.__version__)"

RUN cd submodules/diff-triangle-rasterization && python3 -m pip install --no-build-isolation --no-cache-dir .

RUN python3 -c "import diff_triangle_rasterization; print('diff_triangle_rasterization OK')"

RUN cd submodules/simple-knn && pip install --no-build-isolation --no-cache-dir .

RUN python3 -c "import simple_knn; print('simple_knn OK')"

CMD ["/bin/bash"]