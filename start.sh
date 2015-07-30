#!/bin/bash
useradd -m -s /bin/bash $USER
echo $PASSWD | passwd $USER --stdin
jupyterhub -f /srv/jupyterhub/jupyterhub_config.py
