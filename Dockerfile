FROM node:14 AS builder

RUN apt-get update &&\
  apt-get install -y openjdk-8-jdk &&\
  apt install -y ant
RUN git clone https://github.com/clovid/omero-iviewer.git &&\
  cd omero-iviewer &&\
  npm i &&\
  npm run prod

FROM openmicroscopy/omero-web-standalone:5
USER root
RUN /opt/omero/web/venv3/bin/pip install 'django-cookies-samesite'
COPY --from=builder /omero-iviewer/plugin/omero_iviewer /opt/omero/web/venv3/lib/python3.6/site-packages/omero_iviewer
USER omero-web
