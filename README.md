# cLovid Integration Example

## Current TODOs

- deploy on a real server
- find better auth solution than "log in once to get cookie session"

## Development

### localhost

- Start environment via `docker-compose up -d`
- Open `https://localhost:8443` to ensure omero is running
- Start other webserver via `npx http-server`
- Open `localhost:8080/index.html` to view integration example (you most likely need to adapt the iframe url)

- Rebuild image with `docker-compose build omeroweb`
- Restart omeroweb with `docker-compose restart omeroweb` (needed after change in config)

### for Chris

This is the way it was working before / for Chris:

- Start environment via `docker-compose -f docker-compose.yml -f docker-compose.debug.yml up -d --remove-orphans`

- Rebuild image with `docker-compose -f docker-compose.yml -f docker-compose.debug.yml build omeroweb`

## Notes

### Custom omero web

We need a custom omero web docker image to make the iframe integration work, because we need to set the `SameSite` attribute on the cookies used by omero web. Maybe this step isn't necessary anymore when https://github.com/ome/omero-web/issues/120 is fixed.

We also need the custom omero web docker image because we build and copy the cLovid omero iviewer fork during the image creation.

#### Dockerfiles

We have two Dockerfiles

- `Dockerfile`: This is used for the main project
- `Dockerfile.debug`: This builds an image that we can use for debugging purposes.






TODO:
- update dev
- deploy to ifas server