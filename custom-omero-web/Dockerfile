FROM openmicroscopy/omero-web-standalone:5
USER root
RUN useradd -m chris
RUN echo 'chris:chris' | chpasswd
RUN echo 'omero-web:omero-web' | chpasswd
RUN yum install sudo nginx -y
RUN usermod -aG wheel chris
RUN usermod -aG wheel omero-web
COPY omeroweb.conf /etc/nginx/conf.d/omeroweb.conf
COPY self.crt /opt/self.crt
COPY self.key /opt/self.key
COPY 01-default-webapps.omero /opt/omero/web/config/01-default-webapps.omero
COPY 97-run-nginx.sh /startup/97-run-nginx.sh
RUN chmod 755 /startup/97-run-nginx.sh
RUN echo "omero-web ALL=NOPASSWD: /sbin/nginx" >> /etc/sudoers
USER omero-web
RUN /opt/omero/web/venv3/bin/omero config remove -- omero.web.middleware '{"index": 6, "class": "django.middleware.clickjacking.XFrameOptionsMiddleware"}'

