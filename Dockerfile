# syntax=docker/dockerfile:1
ARG PYTHON_VERSION=3.10
FROM python:$PYTHON_VERSION-slim as base

# More details regarding the annotation can be found at the following URL:
# https://github.com/opencontainers/image-spec/blob/main/annotations.md
LABEL org.opencontainers.image.authors="Gabriel Ichim <gabriel.ichim@outlook.com>" \
      org.opencontainers.image.source="${GITHUB_REPOSITORY}" \
      org.opencontainers.image.version="${GITHUB_SHA}" \
      org.opencontainers.image.revision="${GITHUB_SHA}" \
      org.opencontainers.image.vendor="Local" \
      org.opencontainers.image.title="Python-App-B" \
      org.opencontainers.image.description="With this image you can query the database"

# Print tracebacks on crash [1], and to not buffer stdout and stderr [2].
# [1] https://docs.python.org/3/using/cmdline.html#envvar-PYTHONFAULTHANDLER
# [2] https://docs.python.org/3/using/cmdline.html#envvar-PYTHONUNBUFFERED
ENV PYTHONFAULTHANDLER 1
ENV PYTHONUNBUFFERED 1

# Install development tools: compilers, vim, curl
RUN --mount=type=cache,target=/var/cache/apt/ \
    --mount=type=cache,target=/var/lib/apt/ \
    apt-get update \ 
    && apt-get install --no-install-recommends --yes \
    build-essential=12.9 \
    vim=2:8.2.2434-3+deb11u1 \
    curl=7.74.0-1.3+deb11u7 \
    tini=0.19.0-1 \
    && rm -f /usr/local/src/* \
    && rm -f /tmp/* \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*


# Create the user
ARG USERNAME=pythonuser
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && chown $USERNAME /opt
USER $USERNAME

# Create and activate a virtual environment.
RUN python -m venv /opt/dc-python-app-a-env
ENV PATH /opt/dc-python-app-a-env/bin:$PATH
ENV VIRTUAL_ENV /opt/dc-python-app-a-env


#Set working directory
WORKDIR /workspaces/dc-python-app-a

# Install the run time Python dependencies in the virtual environment.
COPY requirements.txt requirements.txt
RUN pip3 install --no-cache-dir -r requirements.txt


FROM base as application

COPY --chown=$USERNAME:$USERNAME . .

RUN chmod +x docker-entrypoint.sh

# Expose the application
ENTRYPOINT ["/usr/bin/tini", "--", "/workspaces/dc-python-app-a/docker-entrypoint.sh"]

CMD ["python3", "-m" , "flask", "run", "--host=0.0.0.0"]