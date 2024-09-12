# syntax=docker/dockerfile:1
ARG ALPINE_VERSION=3.16.2
ARG ELIXIR_VERSION=1.14.3
ARG ERLANG_VERSION=23.3.4.18

FROM hexpm/elixir:${ELIXIR_VERSION}-erlang-${ERLANG_VERSION}-alpine-${ALPINE_VERSION} AS base

# 설치: 필수 도구 설치 (git, inotify-tools, bash, openssl, jq 등)
RUN apk add --no-cache\
    git\
    inotify-tools\
    bash\
    openssl-dev\
    openssl\
    jq\
    libstdc++\
    coreutils

# Elixir Hex와 Rebar 설치
RUN mix do local.hex --force, local.rebar --force

# 작업 디렉토리 설정
WORKDIR /app/reticulum

# 소스 파일 복사
COPY . .

# 의존성 다운로드
RUN mix deps.get

# tzdata 라이브러리 업데이트 추가
RUN mix deps.update tzdata

# 최종 실행
CMD ["mix", "phx.server"]
