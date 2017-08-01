FROM jeffreymanning/centos-base

MAINTAINER Jeff Manning

USER root

#install the basic packages - nss_wrapper requires epel
RUN yum clean all
RUN yum install -y epel-release && yum -y update && yum clean all

# spark pre-reqs...  if no hadoop, need log4j to install
RUN yum -y install nss_wrapper gettext numpy && yum clean all

## Install Spark
ARG SPARK_MAJOR_VERSION=2
ARG SPARK_UPDATE_VERSION=1
ARG SPARK_MINOR_VERSION=1
ARG SPARK_VERSION=spark-${SPARK_MAJOR_VERSION}.${SPARK_UPDATE_VERSION}.${SPARK_MINOR_VERSION}
ARG SPARK_HREF_ROOT="https://archive.apache.org/dist/spark"

# currently not using hadoop - deploy standalone
ARG DISTRO_NAME_HADOOP=${SPARK_VERSION}-bin-hadoop2.7

## caution with no hadoop...  the slfj...  jars are not included with the binary distribution
ARG DISTRO_NAME_NO_HADOOP=${SPARK_VERSION}-bin-without-hadoop
ARG DISTRO_NAME=${DISTRO_NAME_HADOOP}
ARG DISTRO_LOC=${SPARK_HREF_ROOT}/${SPARK_VERSION}/${DISTRO_NAME}.tgz

RUN cd /opt && \
    curl $DISTRO_LOC \
    | gunzip \
    | tar -x && \
    ln -s $DISTRO_NAME spark

# setup the environment variables for Spark
ENV PATH=$PATH:/opt/spark/bin
ENV SPARK_HOME=/opt/spark

# Adding jmx by default
COPY metrics /opt/spark

# Configuration BLOCK
# Configure Spark
COPY scripts /tmp/scripts
RUN [ "bash", "-x", "/tmp/scripts/spark/install" ]

#cleanp scripts
RUN rm -rf /tmp/scripts

# change ownership to the spark process (non-root)
#RUN chown -R -L spark:spark ${SPARK_HOME}

####  NSS Wrapper setup
# NSS Wrapper to modify /etc/passwd so arbitrary UIDs (185 above) can run and still have a username.
# Useful in environments such as Openshift which randomise the UID for each container
# Use the $USER_NAME environment variable to configure the name for the user.
#
# problem manifests itself in a login failure:
#       Exception in thread "main" java.io.IOException: failure to login
#           at org.apache.hadoop.security.UserGroupInformation.loginUserFromSubject(UserGroupInformation.java:824)
#           ... or equivalent
# looks to be an issue with OS login of users..
# see  https://stackoverflow.com/questions/41864985/hadoop-ioexception-failure-to-login
#
#RUN groupadd -r spark && useradd -r -s /bin/false -d ${SPARK_HOME} -u 185 -g spark spark
#RUN usermod -aG wheel spark
USER 185
#ENV USER_NAME=185
#USER spark
#ENV USER_NAME=spark
ENV NSS_WRAPPER_PASSWD=/tmp/passwd
ENV NSS_WRAPPER_GROUP=/etc/group
RUN touch ${NSS_WRAPPER_PASSWD}  && \
    chgrp 0 ${NSS_WRAPPER_PASSWD} && \
    chmod g+rw ${NSS_WRAPPER_PASSWD}

# Make the default PWD somewhere that the user can write. This is
# useful when connecting with 'oc run' and starting a 'spark-shell',
# which will likely try to create files and directories in PWD and
# error out if it cannot.
WORKDIR /tmp

# entrypoint actually adds user to NSS_WRAPPER_PASSWD (185 and group 185)
ENTRYPOINT ["/entrypoint"]

# Start the main process
CMD ["/opt/spark/bin/launch.sh"]
