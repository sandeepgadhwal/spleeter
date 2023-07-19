FROM ubuntu:22.04

SHELL ["/bin/bash", "--login", "-c"]

RUN apt-get update && apt-get install -y wget ffmpeg libsndfile1 git && rm -rf /var/lib/apt/lists/*

RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/mininconda.sh && \
    sh /tmp/mininconda.sh -b -p /miniconda && \
    rm /tmp/mininconda.sh

ENV PATH=/miniconda/bin:$PATH
ARG PATH=/miniconda/bin:$PATH

RUN conda init bash

RUN conda install -n base conda-libmamba-solver && \
    conda config --set solver libmamba && \
    conda clean -a -y

# Create env
RUN conda create -n spleeter python=3.8 -y && \
    conda clean -a -y
ADD ./conda_env.sh /conda_env.sh 
RUN chmod +x /conda_env.sh

# Install CUDATOOLKIT
ARG CUDA_VERSION=11.8
RUN conda install -n spleeter -y "cudatoolkit=${CUDA_VERSION}" && \
    conda clean -a -y
RUN source /conda_env.sh && pip install nvidia-cudnn-cu11==8.6.0.163 --no-cache-dir
RUN source /conda_env.sh && mkdir -p $CONDA_PREFIX/etc/conda/activate.d && \
    echo 'CUDNN_PATH=$(dirname $(python -c "import nvidia.cudnn;print(nvidia.cudnn.__file__);"))' >> $CONDA_PREFIX/etc/conda/activate.d/env_vars.sh && \
    echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CONDA_PREFIX/lib/:$CUDNN_PATH/lib' >> $CONDA_PREFIX/etc/conda/activate.d/env_vars.sh

# Install spleeter
RUN source /conda_env.sh && pip install git+https://github.com/deezer/spleeter.git#egg=spleeter --no-cache-dir


ENV MODEL_PATH /model
RUN mkdir -p /model

ADD ./entrypoint.sh /entrypoint.sh 
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]