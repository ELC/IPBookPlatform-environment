FROM gnuoctave/octave:9.4.0

RUN apt-get update && \
    apt-get install -y git sqlite3 libsqlite3-dev xvfb x11-apps xkb-data \
                           octave-control octave-image octave-io octave-optim \
                           octave-signal octave-statistics \
                           libgl1-mesa-dri libglu1-mesa mesa-utils
RUN git clone --depth=1 https://github.com/pyenv/pyenv.git "/home/ubuntu/.pyenv"

ENV PYTHON_VERSION=3.11.9
ENV PYENV_ROOT="/home/ubuntu/.pyenv"
ENV PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${PATH}"

RUN pyenv install ${PYTHON_VERSION} && \
    pyenv global ${PYTHON_VERSION}

RUN --mount=type=bind,source=Pipfile,target=Pipfile \
    --mount=type=bind,source=Pipfile.lock,target=Pipfile.lock \
    pip install --no-cache --upgrade pip pipenv==2024.4.1 uv==0.6.3 && \
    pipenv requirements --dev > requirements.txt

RUN uv pip install --system --requirement requirements.txt && \
    pyenv rehash

WORKDIR "/home/ubuntu"
COPY . .
USER root
RUN chmod -R 777 run_xvfb_and_forward.sh
USER ubuntu

ENV DISPLAY=":1"
ENV OCTAVE_EXECUTABLE="/usr/bin/octave"

ENTRYPOINT ["/home/ubuntu/run_xvfb_and_forward.sh"]

# docker build -t my_image . && docker run --rm -it my_image octave --eval "available_graphics_toolkits()"