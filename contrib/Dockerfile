FROM jamesjj/vsts-agent-dockerized:20180603k

ARG DOCKER_RPM="docker-ce-18.03.1.ce-1.el7.centos.x86_64"

## Install Docker (for client)
RUN \
curl -sSf https://download.docker.com/linux/centos/docker-ce.repo -o /etc/yum.repos.d/docker-ce.repo && \
sed -i -e 's#^enabled=.*#enabled=0#'  /etc/yum.repos.d/docker-ce.repo && \
yum install -y --enablerepo=docker-ce-stable "${DOCKER_RPM}" && \
systemctl disable docker

# Install AWS CLI
RUN \
    yum install -y epel-release && \
    yum install -y --enablerepo=epel python-pip && \
    pip install awscli

# "${VSTS_BASE_DIR}/bin/local.sh" will be executed at run time.
# This allows us a way to perform any necessary startup tasks
# e.g. directory permissions in volumes
# e.g. ensuring VSTS user is a member of whichever group
#      has access to "docker.sock"
COPY local.sh "${VSTS_BASE_DIR}/bin/"




