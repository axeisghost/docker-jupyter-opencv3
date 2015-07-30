FROM debian:jessie
MAINTAINER Philipz <philipzheng@gmail.com>

ENV NUM_CORES 4

# Install OpenCV 3.0
RUN apt-get update
RUN apt-get -y install python-dev wget unzip \
                       build-essential cmake git pkg-config libatlas-base-dev gfortran \
                       libjasper-dev libgtk2.0-dev libavcodec-dev libavformat-dev \
                       libswscale-dev libjpeg-dev libpng-dev libtiff-dev libjasper-dev libv4l-dev
RUN wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py
RUN pip install numpy matplotlib

RUN wget https://github.com/Itseez/opencv/archive/3.0.0.zip -O opencv3.zip && \
    unzip -q opencv3.zip && mv /opencv-3.0.0 /opencv
RUN wget https://github.com/Itseez/opencv_contrib/archive/3.0.0.zip -O opencv_contrib3.zip && \
    unzip -q opencv_contrib3.zip && mv /opencv_contrib-3.0.0 /opencv_contrib
RUN mkdir /opencv/build
WORKDIR /opencv/build
RUN cmake -D CMAKE_BUILD_TYPE=RELEASE \
	-D BUILD_PYTHON_SUPPORT=ON \
	-D CMAKE_INSTALL_PREFIX=/usr/local \
	-D INSTALL_C_EXAMPLES=ON \
	-D INSTALL_PYTHON_EXAMPLES=ON \
	-D OPENCV_EXTRA_MODULES_PATH=/opencv_contrib/modules \
	-D BUILD_EXAMPLES=ON \
	-D BUILD_NEW_PYTHON_SUPPORT=ON \
	-D WITH_IPP=OFF \
	-D WITH_V4L=ON ..
RUN make -j$NUM_CORES
RUN make install
RUN ldconfig

# Install Jupyter
WORKDIR /
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get install -y git vim wget build-essential python-dev ca-certificates bzip2 libsm6 && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV CONDA_DIR /opt/conda

# Install conda for the jovyan user only (this is a single user container)
RUN echo 'export PATH=$CONDA_DIR/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-3.9.1-Linux-x86_64.sh && \
    /bin/bash /Miniconda3-3.9.1-Linux-x86_64.sh -b -p $CONDA_DIR && \
    rm Miniconda3-3.9.1-Linux-x86_64.sh && \
    $CONDA_DIR/bin/conda install --yes conda==3.10.1

# We run our docker images with a non-root user as a security precaution.
# jovyan is our user
RUN useradd -m -s /bin/bash jovyan
RUN chown -R jovyan:jovyan $CONDA_DIR

EXPOSE 8888

USER jovyan
ENV HOME /home/jovyan
ENV SHELL /bin/bash
ENV USER jovyan
ENV PATH $CONDA_DIR/bin:$PATH
WORKDIR $HOME

USER jovyan

RUN conda install --yes ipython-notebook terminado && conda clean -yt

RUN ipython profile create

# Workaround for issue with ADD permissions
USER root
ADD profile_default /home/jovyan/.ipython/profile_default
ADD templates/ /srv/templates/
RUN chmod a+rX /srv/templates
RUN chown jovyan:jovyan /home/jovyan -R
USER jovyan

# Expose our custom setup to the installed ipython (for mounting by nginx)
RUN cp /home/jovyan/.ipython/profile_default/static/custom/* /opt/conda/lib/python3.4/site-packages/IPython/html/static/custom/

# Convert notebooks to the current format
RUN find . -name '*.ipynb' -exec ipython nbconvert --to notebook {} --output {} \;
RUN find . -name '*.ipynb' -exec ipython trust {} \;

CMD ipython notebook
