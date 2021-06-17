FROM centos:7

# Layer: base
RUN yum install -y http://repository.egi.eu/sw/production/umd/4/centos7/x86_64/updates/umd-release-4.1.3-1.el7.centos.noarch.rpm && \
    yum install -y https://yum.puppet.com/puppet5/puppet5-release-el-7.noarch.rpm && \
    yum install -y git puppet redhat-lsb && \
    yum clean all

# Layer: Argus BDII
EXPOSE 2170

COPY run.sh /
COPY manifest.pp /

RUN chmod +x /run.sh
CMD /run.sh
