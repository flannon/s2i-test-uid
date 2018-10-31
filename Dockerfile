
# s2i-builder-rpm
FROM openshift/base-centos7
#FROM centos/s2i-core-centos7

MAINTAINER Flannon Jackson <flannon@nyu.edu>

ENV BUILDER_VERSION 0.1.0

LABEL io.k8s.description="Platform for building src rpms" \
      io.k8s.display-name="builder rpm" \
      io.openshift.expose-services="" \
      io.openshift.tags="builder,rpm,etc." 

RUN yum install -y epel-release \
    && yum clean all -y

### Setup user for build execution and application runtime
ENV APP_ROOT=/opt/app-root
ENV PATH=${APP_ROOT}/bin:${PATH} HOME=${APP_ROOT}
COPY bin/ ${APP_ROOT}/bin/
#COPY ./build.sh ${HOME}/build.sh
RUN chmod -R u+x ${APP_ROOT}/bin && \
    chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT} /etc/passwd
    #chown -R 1001:0 /opt/app-root && \
    #chmod -R 775 /opt/app-root


COPY ./s2i/bin/ /usr/libexec/s2i

# This default user is created in the openshift/base-centos7 image
USER 1001
WORKDIR ${APP_ROOT}

### user name recognition at runtime w/ an arbitrary uid - for OpenShift deployments
VOLUME ${APP_ROOT}/logs ${APP_ROOT}/data
CMD ["/usr/libexec/s2i/run"]
