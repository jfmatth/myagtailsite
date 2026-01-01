# My Wagtail site

First attempt at following the tutorial and then dockerizing for local and K8s usage.

## Building images for Podman
We will use the build powershell script to build our image locall, need two files:
- IMAGE - the ghcr.io path for the image  
- VERSION - the tag we'll put on the image  

```
build
```


## Running

Wagtail ```DJANGO_SETTINGS_MODULE``` defaults to ```core.dev.py```

### Locally
Just Django ```runserver``` nothing fancy.

### Podman local
Need a Postgres DB to host all this good stuff

```
podman pod create -p 8000:8000 wagtail
podman volume create dbdata

podman run -d `
--name wagtail-db `
--pod wagtail `
--env-file ENV-dev `
-v dbdata:/var/lib/postgresql/data/ `
postgres:17
```