FROM centos:7

ARG VSTS_BASE_DIR="/opt/vsts"
ARG VSTS_LINUX_USER="vsts"
ARG VSTS_VERSION="2.160.0"
ARG TINI_VERSION="v0.18.0"

ENV VSTS_BASE_DIR="${VSTS_BASE_DIR}"
ENV VSTS_LINUX_USER="${VSTS_LINUX_USER}"
ENV VSTS_VERSION="${VSTS_VERSION}"

# ENV agent.disableupdate=true

# General Update
RUN \
yum -y --obsoletes update && \
yum -y install sudo bsdtar

## Install dependencies including: Git 2.x

RUN \
yum install -y centos-release-scl libunwind.x86_64 icu && \
yum install -y rh-git29.x86_64 && \
echo 'source scl_source enable rh-git29' > /etc/profile.d/git29.sh && \
chmod 644 /etc/profile.d/git29.sh && \
source scl_source enable rh-git29 && \
git --version

# Better to run this under an init: Add Tini
RUN \
curl -sSfL -o /opt/tini https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static && \
chmod 755 /opt/tini

## Install VSTS (prepare)
RUN \
useradd -u 1001 -c VSTS -m -U "${VSTS_LINUX_USER}" && \
mkdir -p "${VSTS_BASE_DIR}/agent" && \
mkdir -p "${VSTS_BASE_DIR}/bin" && \
mkdir -p "${VSTS_BASE_DIR}/tmp/_work" && \
chown -R "${VSTS_LINUX_USER}" "${VSTS_BASE_DIR}"

## Install VSTS (on-build)
ONBUILD RUN \
curl --progress-bar -sSf -o /opt/vsts/agent/agent.tar.gz \
  "https://vstsagentpackage.azureedge.net/agent/${VSTS_VERSION}/vsts-agent-linux-x64-${VSTS_VERSION}.tar.gz" && \
cd "${VSTS_BASE_DIR}/agent" && \
bsdtar -xzf agent.tar.gz && \
chown -R "${VSTS_LINUX_USER}" "${VSTS_BASE_DIR}" && \
ln -s ../bin/vsts_runtime.sh

ENTRYPOINT ["/opt/tini", "-g", "--"]

WORKDIR "${VSTS_BASE_DIR}/agent"

VOLUME "${VSTS_BASE_DIR}/tmp"

COPY vsts_runtime.sh "${VSTS_BASE_DIR}/bin/"

CMD [ "bash", "vsts_runtime.sh" ]

