FROM python:3.9-alpine3.13
LABEL mantainer="gbattiston"

ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /tmp/requirements.txt 
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

ARG DEV=false
RUN python -m venv /py && \ 
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

# create a virtual environment
# specify the full path of the virtual env
# install requirements files
# remove the tmp directory because we don't want any extra dependency in the env
# add a new user inside the image (best practice not use the root user)
# he will be the default user, so he doesn't need a password

# updates the environment virable
ENV PATH="/py/bin:$PATH"

# specify the user to switch to
USER django-user