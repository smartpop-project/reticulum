FROM hexpm/elixir:1.14.3-erlang-23.3.4.18-debian-buster-20220801
RUN mix do local.hex --force, local.rebar --force

# # FROM base AS dev
# RUN apk add --no-cache\
#     # required by hex\
#     git\
#     # required by hex:phoenix_live_reload\
#     inotify-tools

# RUN apk update && apk add --no-cache bash openssl-dev openssl jq libstdc++ coreutils

# Hex에 필요한 git 설치
RUN apt-get update && apt-get install -y git

# Hex:phoenix_live_reload에 필요한 inotify-tools 설치
RUN apt-get install -y inotify-tools

# bash, openssl, jq, libstdc++, coreutils 설치
RUN apt-get install -y bash openssl libssl-dev jq libstdc++6 coreutils
