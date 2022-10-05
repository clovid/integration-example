# cLovid Integration Example

## Current TODOs

- deploy on a real server
- find better auth solution than "log in once to get cookie session"
- find good workflow to work on iviewer fork

## Development

### localhost

- Start environment via `docker-compose up -d`
- Open `https://localhost:8443` to ensure omero is running
- Start other webserver via `npx http-server`
- Open `localhost:8080/index.html` to view integration example (you most likely need to adapt the iframe url)

#### Misc
- Rebuild image with `docker-compose build omeroweb`
- Restart omeroweb with `docker-compose restart omeroweb` (needed after change in config)
- Log omeroweb with `docker-compose logs -f -t --tail=10 omeroweb` (f: follow, t: timestamps)

### for Chris

This is the way it was working before / for Chris:

- Start environment via `docker-compose -f docker-compose.yml -f docker-compose.debug.yml up -d --remove-orphans`

#### Misc
- Rebuild image with `docker-compose -f docker-compose.yml -f docker-compose.debug.yml build omeroweb`

### Development of iViewer

To use a local iViewer instance (e.g. during development on our iViewer fork) we need to run the [cLovid iViewer](https://github.com/clovid/omero-iviewer): `npm run dev`. Make sure to configure an existing start image id (see README of the iViewer fork).
Use the following URL in the iframe to use the local iViewer: `http:localhost:8080`.

## Production

For production we use the following command: `docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d`

## Notes

### Custom omero web

We need a custom omero web docker image to make the iframe integration work, because we need to set the `SameSite` attribute on the cookies used by omero web. Maybe this step isn't necessary anymore when https://github.com/ome/omero-web/issues/120 is fixed.

We also need the custom omero web docker image because we build and copy the cLovid omero iviewer fork during the image creation.

#### Dockerfiles

We have two Dockerfiles

- `Dockerfile`: This is used for the main project
- `Dockerfile.debug`: This builds an image that we can use for debugging purposes.

### Import via CLI

docker-compose exec omeroserver /bin/bash
alias omero='/opt/omero/server/OMERO.server/bin/omero'
omero -s localhost -u root login
omero obj new Dataset name=image_1
omero import -d Dataset:[id] [image]

### Misc

#### Helpful omero server infos

- https://docs.openmicroscopy.org/omero/5.6.3/sysadmins/server-performance.html
- https://forum.image.sc/t/omero-pyramid-generation-time/33463/26

omero admin diagnostics
omero admin jvmcfg
omero config get

- cat PixelData-0.log | grep "Pyramid creation"

#### Performance

- https://docs.openmicroscopy.org/omero/5.3.5/sysadmins/unix/install-web/web-deployment.html
- https://github.com/ome/prod-playbooks/blob/master/omero/ome-demoserver.yml
- https://github.com/ome/prod-playbooks/tree/d604a0c9db28c83414bd6fb0c38362b9722cf1bf
- https://medium.com/building-the-system/gunicorn-3-means-of-concurrency-efbb547674b7
- https://docs.loadforge.com/docs/misc-nginx
- https://www.digitalocean.com/community/tutorials/how-to-optimize-nginx-configuration
- https://www.digitalocean.com/community/tutorials/how-to-set-up-nginx-with-http-2-support-on-ubuntu-20-04
- https://stackoverflow.com/questions/36014554/how-to-change-the-default-location-for-docker-create-volume-command

### Demo WSI images

- https://downloads.openmicroscopy.org/images/
