FROM openmicroscopy/omero-web-standalone:5
USER root
RUN /opt/omero/web/venv3/bin/pip install 'django-cookies-samesite'
USER omero-web
