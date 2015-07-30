#!/bin/bash
useradd -m -s /bin/bash $USER
echo "$USER:$PASSWD" | chpasswd
jupyterhub -f /srv/jupyterhub/jupyterhub_config.py
