# Example: VSTS Agent with 'Docker' and AWS CLI

The `Dockerfile` in this directory is an example of how to use the `jamesjj/vsts-agent-dockerized` base image to build a container that can execute VSTS build tasks using Docker and AWS CLI.

*You should mount the docker socket `/var/run/docker.sock` in to the container, if you want to use `docker` CLI commands*
