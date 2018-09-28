# The version of Alpine to use for the final image
# This should match the version of Alpine that the `elixir:1.7.2-alpine` image uses
ARG ALPINE_VERSION=3.8

FROM elixir:1.7.2-alpine AS builder

# The following are build arguments used to change variable parts of the image.
# The name of your application/release (required)
ARG APP_NAME=pallium
# The version of the application we are building (required)
ARG APP_VSN=0.1.0
# The environment to build with
ARG MIX_ENV=prod
# Set this to true if this release is not a Phoenix app
ARG SKIP_PHOENIX=true
# If you are using an umbrella project, you can change this
# argument to the directory the Phoenix app is in so that the assets
# can be built
ARG PHOENIX_SUBDIR=.

ENV SKIP_PHOENIX=${SKIP_PHOENIX} \
    APP_NAME=${APP_NAME} \
    APP_VSN=${APP_VSN} \
    MIX_ENV=${MIX_ENV}


# This step installs all the build tools we'll need
RUN apk update && \
  apk upgrade --no-cache && \
  apk add --no-cache \
    nodejs \
    yarn \
    git \
    curl \
    build-base && \
  mix local.rebar --force && \
  mix local.hex --force

WORKDIR /opt/tm

RUN curl -o tendermint.zip -L https://github.com/tendermint/tendermint/releases/download/v0.22.8/tendermint_0.22.8_linux_amd64.zip
RUN unzip tendermint.zip
RUN rm tendermint.zip
RUN ./tendermint init

# By convention, /opt is typically used for applications
WORKDIR /opt/app

# This copies our app source code into the build container
COPY . .

RUN mix do deps.clean --all, deps.get, deps.compile, compile

ENV REPLACE_OS_VARS=true \
    APP_NAME=${APP_NAME} \
    TENDERMINT_PRIV_VALIDATOR=/root/.tendermint/config/priv_validator.json


# CMD trap 'exit' INT; /opt/app/bin/${APP_NAME} foreground
# CMD iex -S mix
CMD /bin/sh
