# Base Image
FROM ubuntu:18.04 as base

RUN useradd -ms /bin/bash cfeuser

# set working directory
WORKDIR /home/cfeuser/src/


# set default environment variables
ENV PYTHONUNBUFFERED 1
ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive 


# Install Ubuntu dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        tzdata \
        libopencv-dev \ 
        build-essential \
        libssl-dev \
        libpq-dev \
        libcurl4-gnutls-dev \
        libexpat1-dev \
        gettext \
        unzip \
        supervisor \
        python3-setuptools \
        python3-pip \
        python3-dev \
        python3-venv \
        git \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# install environment dependencies
RUN pip3 install --upgrade pip 
RUN pip3 install psycopg2 pipenv

# Install project dependencies
COPY ./Pipfile /home/cfeuser/src/Pipfile
RUN pipenv install --skip-lock --system --dev


# Install TensorFlow CPU version from central repo
RUN pip3 --no-cache-dir install tensorflow keras

# ENV LD_LIBRARY_PATH /usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH

# Install OpenCV
RUN apt-get update && apt-get install -y  python-opencv && echo 'ln /dev/null /dev/raw1394' >> ~/.bashrc
RUN pip3 install opencv-contrib-python

# Install PyTorch and Fastai
# RUN pip3 install torch torchvision
# RUN pip3 install fastai

# copy project to working dir
COPY . /home/cfeuser/src/

# update the jupyter configuration
RUN jupyter notebook --generate-config

RUN rm /root/.jupyter/jupyter_notebook_config.py
COPY ./conf/notebook-conf.py /root/.jupyter/jupyter_notebook_config.py

CMD jupyter notebook --config=/root/.jupyter/jupyter_notebook_config.py # --no-browser --no-mathjax --ip=* --port $PORT

