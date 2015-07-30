# docker-jupyter-opencv3
## Reference
[Jupyter Dockerfile](https://github.com/jupyter/jupyterhub/blob/master/Dockerfile)

[OpenCV3](http://www.pyimagesearch.com/2015/07/20/install-opencv-3-0-and-python-3-4-on-ubuntu/)

[OpenCV3 Dockerfile](https://github.com/philipz/docker-opencv3/tree/3.4)
## How to Use
docker run -d --name jupyter -e $USER=NAME -e $PASSWD=1234 -v $(pwd):/home/jovyan/opencv -p 8000:8000 philipz/jupyter-opencv3
