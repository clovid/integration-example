FROM node:16 AS builder

RUN apt-get update &&\
  apt-get install -y openjdk-11-jdk &&\
  apt install -y ant
ADD https://api.github.com/repos/clovid/omero-iviewer/commits/main /latest-commit.json
RUN git clone --branch main https://github.com/clovid/omero-iviewer.git &&\
  cd omero-iviewer &&\
  npm i &&\
  npm run prod

FROM openmicroscopy/omero-web-standalone:5
USER root
COPY --from=builder /omero-iviewer/plugin/omero_iviewer /opt/omero/web/venv3/lib/python3.9/site-packages/omero_iviewer_clovid
USER omero-web
