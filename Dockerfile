FROM python:3.9-alpine3.13
# specigy the maintainer of the Dockerfile (best practice)
LABEL maintainer="Adam Zhang" 
# make python unbuffer (best practice)
ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt

COPY ./app /app
WORKDIR /app
EXPOSE 8000

# 1.建立虚拟环境，装requirements.txt; best practice, 也是为了万一system dependencies改变，不用重建整个image
# 2. 删除/tmp; keep image minimum
# 3. 创建用户django-user. Best practice to run the container as non-root user
# Note: && to chain commands together so we can reduce # of layers

# set build arg DEV
ARG DEV=false

RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ "$DEV" = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt; \
    fi && \
    rm -rf /tmp && \
    adduser \
        --disabled-password \
        --no-create-home \ 
        django-user

# update the PATH environment variable; 这样每次python command都会run了虚拟环境中的python，而不是系统python
ENV PATH="/py/bin:$PATH"

USER django-user


