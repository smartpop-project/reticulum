# syntax=docker/dockerfile:1
ARG ALPINE_VERSION=3.16.2
ARG ELIXIR_VERSION=1.14.3
ARG ERLANG_VERSION=23.3.4.18

FROM hexpm/elixir:${ELIXIR_VERSION}-erlang-${ERLANG_VERSION}-alpine-${ALPINE_VERSION} AS base
RUN mix do local.hex --force, local.rebar --force

# FROM base AS dev
RUN apk add --no-cache\
    # required by hex\
    git\
    # required by hex:phoenix_live_reload\
    inotify-tools

RUN apk update && apk add --no-cache bash openssl-dev openssl jq libstdc++ coreutils

WORKDIR /app
COPY ./reticulum ./reticulum

WORKDIR /app/reticulum

RUN mix deps.get
