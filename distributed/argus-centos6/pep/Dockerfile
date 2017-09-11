FROM centos:6.9

# Layer: base
RUN rpm -ivh https://yum.puppet.com/puppet5/puppet5-release-el-6.noarch.rpm && \
    yum install -y http://repository.egi.eu/sw/production/umd/3/sl6/x86_64/base/umd-release-3.0.0-1.el6.noarch.rpm && \
    yum update -y && yum install -y git puppet redhat-lsb epel-release wget && \
    yum clean all

# Layer: Argus PEP
EXPOSE 8154
EXPOSE 8155

COPY run.sh /
COPY manifest.pp /

CMD /run.sh
