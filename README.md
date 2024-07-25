# Jupyter Hub and Infrastructure

This repository includes all of the deployment files of the infrastructure as well as configuration of JupyterHub.

## Jupyter Hub

- [Jupyter Server Swagger API Doc](https://petstore.swagger.io/?url=https://raw.githubusercontent.com/jupyter/jupyter_server/master/jupyter_server/services/api/api.yaml)
- [Jupyter Hub Swagger API Doc](https://jupyterhub.readthedocs.io/en/latest/reference/rest-api.html)

### Notes about JupyterHub:

- Jupyter Server: backend of the Jupyter service that controls the session management, kernel communication and so on
    - When you run Jupyter Server, it only runs for single user so if multiple users want to use it at the same time, their commands may collide
- Jupyter Hub: multi-user Jupyter server
- JupyterHub for kubernetes: https://z2jh.jupyter.org/en/latest/
- Jupyter Server and Frontend talks via websockets for kernel communication:
    - https://jupyter-server.readthedocs.io/en/latest/developers/websocket-protocols.html
    - https://jupyter-client.readthedocs.io/en/stable/messaging.html#the-wire-protocol
    - https://github.com/jupyter/jupyter/wiki/Jupyter-Notebook-Server-API


## Infrastructure

- Architecture Diagram can be found in the root repository as a PlantUML in `architecture-diagram.uml` file (but it is not up-to-date). The up-to-date architecture diagram is loaded as a png file which derived by using Lucid.app

