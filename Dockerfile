FROM elixir:alpine

ADD https://php.codecasts.rocks/php-alpine.rsa.pub /etc/apk/keys/php-alpine.rsa.pub
RUN apk --update add ca-certificates
RUN echo "@php https://php.codecasts.rocks/v3.7/php-7.2" >> /etc/apk/repositories
RUN apk add --no-cache alpine-sdk autoconf nodejs git automake libtool libsecp256k1@php

RUN git clone https://github.com/peterromfeldhk/poa-explorer.git

ENV MIX_ENV prod
ENV PORT ${PORT:-4000}
EXPOSE $PORT

WORKDIR /poa-explorer

#RUN sed -i 's/coin: "POA"/coin: "TKC"/g' apps/*/config/config.exs
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix do deps.get --only prod, deps.compile, compile
RUN cd /poa-explorer/apps/explorer_web/assets && npm install && npm run-script deploy && cd /poa-explorer/apps/explorer_web && mix phx.digest
RUN cd /poa-explorer/apps/explorer && npm install

COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["mix", "phx.server"]
