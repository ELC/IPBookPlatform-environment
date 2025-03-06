FROM gnuoctave/octave:9.4.0

RUN apt-get update && \
    apt-get install -y git libsqlite3-dev libffi-dev xvfb \
                           octave-control octave-image octave-io octave-optim \
                           octave-signal octave-statistics \
                           libgl1-mesa-dri libglu1-mesa mesa-utils

COPY --from=ghcr.io/astral-sh/uv:0.6.3 /uv /uvx /bin/
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen --no-install-project --compile-bytecode && \
    ln $(find .venv/bin -type f) /usr/bin/ && \
    ln /usr/bin/jupyter-lab /usr/bin/jupyterlab

WORKDIR "/home/ubuntu"
COPY --chown=ubuntu:ubuntu . .
USER ubuntu

ENV DISPLAY=":1"
ENV OCTAVE_EXECUTABLE="/usr/bin/octave"

ENTRYPOINT ["bash", "-c", "set -e; Xvfb $DISPLAY -screen 0 1024x768x16 & sleep 2 && exec \"$@\" 2>&1 | tee .jupyter-server-log.txt", "--"]


# docker build -t my_image . && docker run --rm -it my_image octave --eval "available_graphics_toolkits()"