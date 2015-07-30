# docker-jupyter-opencv3
## Reference
[Jupyter Dockerfile](https://github.com/jupyter/docker-demo-images/blob/master/common/Dockerfile)
[OpenCV3](http://www.pyimagesearch.com/2015/07/20/install-opencv-3-0-and-python-3-4-on-ubuntu/)
[OpenCV3 Dockerfile](https://github.com/philipz/docker-opencv3/tree/3.4)
## How to Use
docker run -d --name jupyter -v $(pwd):/home/jovyan/opencv -p 8888:8888 philipz/jupyter-opencv3
