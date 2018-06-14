FROM centos:7

# Layer: base
RUN yum install -y http://linuxsoft.cern.ch/wlcg/centos7/x86_64/wlcg-repo-1.0.0-1.el7.noarch.rpm && \
    yum install -y http://repository.egi.eu/sw/production/umd/4/centos7/x86_64/updates/umd-release-4.1.3-1.el7.centos.noarch.rpm && \
    yum install -y https://yum.puppet.com/puppet5/puppet5-release-el-7.noarch.rpm && \
    yum update -y && \
    yum install -y git puppet redhat-lsb wget && \
    yum clean all

# Layer: Argus PEP
EXPOSE 8154
EXPOSE 8155

COPY run.sh /
COPY manifest.pp /

RUN chmod +x /run.sh
CMD /run.sh
