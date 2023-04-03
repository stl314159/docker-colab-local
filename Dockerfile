ARG CUDA_VERSION=12.1.0

FROM nvidia/cuda:${CUDA_VERSION}-base-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8

RUN ln -snf /usr/share/zoneinfo/$CONTAINER_TIMEZONE /etc/localtime && echo $CONTAINER_TIMEZONE > /etc/timezone

# install Python
ARG _PY_SUFFIX_MAJOR=3
ARG _PY_SUFFIX_MINOR=9
ARG PYTHON=python${_PY_SUFFIX_MAJOR}
ARG PIP=pip${_PY_SUFFIX_MAJOR}

RUN apt-get update && apt-get -y dist-upgrade

RUN apt-get install -y \
    ${PYTHON}.${_PY_SUFFIX_MINOR} \
    ${PYTHON}.${_PY_SUFFIX_MINOR}-dev \
    ${PYTHON}.${_PY_SUFFIX_MINOR}-venv \
    ${PYTHON}-wheel \
    ${PYTHON}-pip \
    build-essential \
    git \
    libcairo2-dev \
    libdbus-1-dev \
    libgdal-dev \
    libgirepository1.0-dev \
    libpq-dev \
    pkg-config

RUN ${PIP} --no-cache-dir install --upgrade \
    pip \
    setuptools

RUN ln -s $(which ${PYTHON}) /usr/local/bin/python

RUN mkdir -p /opt/colab

WORKDIR /opt/colab

RUN ${PYTHON}.${_PY_SUFFIX_MINOR} -m venv /opt/venv

# Install packages packages
# COPY requirements.txt .
# RUN  . /opt/venv/bin/activate && pip install -r requirements.txt

RUN . /opt/venv/bin/activate && pip install jupyter jupyter_http_over_ws colab-dev-tools torch torchvision

RUN . /opt/venv/bin/activate && jupyter serverextension enable --py jupyter_http_over_ws \
    && jupyter nbextension enable --py widgetsnbextension

ARG COLAB_PORT=8081
EXPOSE ${COLAB_PORT}
ENV COLAB_PORT ${COLAB_PORT}

CMD . /opt/venv/bin/activate && jupyter notebook --NotebookApp.allow_origin='https://colab.research.google.com' --allow-root --port $COLAB_PORT --NotebookApp.port_retries=0 --ip 0.0.0.0
