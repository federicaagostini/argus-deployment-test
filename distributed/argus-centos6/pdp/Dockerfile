FROM centos:6.9

# Layer: base
RUN rpm -ivh https://yum.puppet.com/puppet5/puppet5-release-el-6.noarch.rpm && \
    yum install -y epel-release && \
    yum install -y git puppet redhat-lsb wget voms-api-java && \
    yum install -y http://repository.egi.eu/sw/production/umd/4/sl6/x86_64/updates/umd-release-4.1.3-1.el6.noarch.rpm && \
    yum update -y && \
    yum clean all

# Layer: Argus PDP
EXPOSE 8152
EXPOSE 8153

COPY run.sh /
COPY manifest.pp /

RUN chmod +x /run.sh
CMD /run.sh
