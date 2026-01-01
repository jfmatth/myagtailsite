## Phsae 1 - builder

    # Chainguard python-dev has UV installed
    FROM cgr.dev/chainguard/python:latest-dev as builder
    # FROM python:alpine  as builder

    ENV LANG=C.UTF-8
    ENV PYTHONDONTWRITEBYTECODE=1
    ENV PYTHONUNBUFFERED=1

    USER root

    RUN apk add tzdata

    # use /app generic folder
    WORKDIR /app

    # use python venv to bring in any necessary packages
    # RUN python -m venv /app/venv
    COPY pyproject.toml  .
    RUN uv sync 

## Phase 2 - execution

    # FROM python:alpine 
    FROM cgr.dev/chainguard/python

    WORKDIR /app

    ENV PYTHONUNBUFFERED=1
    ENV PATH="/app/.venv/bin:$PATH"

    # bring in the virtual environment / packages from the builder directory
    COPY --from=builder /app/.venv /app/.venv
    # copy timezone data
    COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo

    # copy application files to WORKDIR (/app)
    COPY manage.py /app
    COPY core/ /app/core
    COPY home/ /app/home
    COPY search/ /app/search

    COPY static /app/static

    EXPOSE 8000

    USER 1000:1000
    
    # ENV DD_AGENT_HOST=datadog-agent.datadog.svc.cluster.local

    # run line for app
    # ENTRYPOINT [ "ddtrace-run","uvicorn", "--host", "0.0.0.0", "core.asgi:application"]
    ENTRYPOINT [ "gunicorn", "core.wsgi:application"]


# # Use an official Python runtime based on Debian 12 "bookworm" as a parent image.
# FROM python:3.12-slim-bookworm

# # Add user that will be used in the container.
# RUN useradd wagtail

# # Port used by this container to serve HTTP.
# EXPOSE 8000

# # Set environment variables.
# # 1. Force Python stdout and stderr streams to be unbuffered.
# # 2. Set PORT variable that is used by Gunicorn. This should match "EXPOSE"
# #    command.
# ENV PYTHONUNBUFFERED=1 \
#     PORT=8000

# # Install system packages required by Wagtail and Django.
# RUN apt-get update --yes --quiet && apt-get install --yes --quiet --no-install-recommends \
#     build-essential \
#     libpq-dev \
#     libmariadb-dev \
#     libjpeg62-turbo-dev \
#     zlib1g-dev \
#     libwebp-dev \
#  && rm -rf /var/lib/apt/lists/*

# # Install the application server.
# # RUN pip install "gunicorn==20.0.4"

# # Install the project requirements.
# COPY requirements.txt /
# RUN pip install -r /requirements.txt

# # Use /app folder as a directory where the source code is stored.
# WORKDIR /app

# # Set this directory to be owned by the "wagtail" user. This Wagtail project
# # uses SQLite, the folder needs to be owned by the user that
# # will be writing to the database file.
# RUN chown wagtail:wagtail /app

# # Copy the source code of the project into the container.
# COPY --chown=wagtail:wagtail . .

# # Use user "wagtail" to run the build commands below and the server itself.
# USER wagtail

# # Collect static files.
# # RUN python manage.py collectstatic --noinput --clear

# # Runtime command that executes when "docker run" is called, it does the
# # following:
# #   1. Migrate the database.
# #   2. Start the application server.
# # WARNING:
# #   Migrating database at the same time as starting the server IS NOT THE BEST
# #   PRACTICE. The database should be migrated manually or using the release
# #   phase facilities of your hosting platform. This is used only so the
# #   Wagtail instance can be started with a simple "docker run" command.
# CMD set -xe; python manage.py migrate --noinput; gunicorn core.wsgi:application
