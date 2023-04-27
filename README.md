# cLovid Integration Example

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
- Update images with `docker-compose pull omeroserver` or `docker-compose build --pull omeroweb`

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

We need a custom omero web docker image to make the iframe integration work, because we need to set the `SameSite` attribute on the cookies used by omero web (by using django-cookies-samesite). Maybe this step isn't necessary anymore when https://github.com/ome/omero-web/issues/120 is fixed.

We also need the custom omero web docker image because we build and copy the cLovid omero iviewer fork (https://github.com/clovid/omero-iviewer) during the image creation.

#### Dockerfiles

We have two Dockerfiles

- `Dockerfile`: This is used for the main project
- `Dockerfile.debug`: This builds an image that we can use for debugging purposes.

### Image converting notes

- Install QuPath: https://github.com/qupath/qupath/releases/tag/v0.3.2
- Install Openslide: apt-get install openslide-tools

alias QuPath='/mnt/volume_fra1_01/tools/QuPath/bin/QuPath'
QuPath convert-ome -d 1 -y 4 -c JPEG --tile-size=256 -p input.mrxs output_jpeg_d-1_y-4_256px.ome.tif


### Import images via CLI

docker-compose exec omeroserver /bin/bash
alias omero='/opt/omero/server/OMERO.server/bin/omero'
omero -s localhost -u root login
omero obj new Dataset name=image_1
omero import -d Dataset:[id] [image]

### Misc

#### Using omero-cli-transfer

To use the helpful tool https://github.com/ome/omero-cli-transfer we can use our adapted dockerized version: https://github.com/clovid/docker-omero-cli-transfer. For this we only have to expose the server port `4064` in the `docker-compose.prod.yml` file.


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
- https://github.com/ome/prod-playbooks/blob/3b3d2e0f2f1f048b2219c9094d7bef8cb43ae6fc/learning.yml#L54-L56
- https://medium.com/building-the-system/gunicorn-3-means-of-concurrency-efbb547674b7
- https://docs.loadforge.com/docs/misc-nginx
- https://www.digitalocean.com/community/tutorials/how-to-optimize-nginx-configuration
- https://www.digitalocean.com/community/tutorials/how-to-set-up-nginx-with-http-2-support-on-ubuntu-20-04
- https://stackoverflow.com/questions/36014554/how-to-change-the-default-location-for-docker-create-volume-command
- https://docs.openmicroscopy.org/omero/5.6.3/developers/Server/ScalingOmero.html
- https://forum.image.sc/t/error-504-when-many-users-log-in-to-omero-web-simultaneously/45084
- https://docs.openmicroscopy.org/omero/5.6.3/developers/Server/ScalingOmero.html

#### Load testing

- https://www.artillery.io/docs/guides/guides/http-reference
- https://github.com/artilleryio/artillery-engine-playwright#configuration
- https://goaccess.io/
- https://docs.locust.io/
-

### Demo WSI images

- https://downloads.openmicroscopy.org/images/


# TODO (Later)
- use https://github.com/krakenjs/post-robot for communication with iframes

# About 3rd party cookies

We need to authenticate ourselves when using the Omero iViewer. For initial authentication we use a "bsession" parameter.
All following requests are using a session cookie for authentication per default. The session cookie is set when requesting the initial page.

The default behavior of modern browsers is to deny cookies that are set by a 3rd party. That means in our case, if we integrate Omero via an iframe it is considered as a 3rd party and the browser doesn't allow the cookie setting therefore the session cookie is not set and the following request respond with an authentication error.

We now have different options to make this work:

- a) Enable 3rd party cookies in the browser
  - no implementation needed
  - doesn't work per default -> users have to change settings
- b) Add the "bsession" parameter to each of the following requests
  - implementation in iviewer needed
  - increased loading time for every request because Omero creates an internal session when getting a "bsession" parameter and doing that for every request (and not just the initial page) increased the server load
  - would work per default -> users don't have to change settings
- c) Use a subdomain of the domain that implements the iframe to Omero iViewer and which proxies the requests to the Omero instance (for example: vquest.eu contains iframe to omero.vquest.eu which is a proxy to omero.clovid.org)
  - only minor changes necessary
    - subdomain with CNAME DNS entry or ngxin `proxy_pass` (if we don't have an access to the DNS table)
    - new SSL certificate
  - would work per default
  - Additional upside: Fullscreen in Chrome seems to work better, if iframe and webpage have the same domain.