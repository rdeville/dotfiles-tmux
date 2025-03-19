FROM alpine:3

WORKDIR /etc/fonts

RUN cat /etc/resolv.conf | grep nameserver
RUN apk update \
  && apk --no-cache add tmux=3.5 \
  && wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/FiraCode.zip \
  && unzip FiraCode.zip \
  && rm FiraCode.zip \
  && fc-cache -fv

WORKDIR /root
