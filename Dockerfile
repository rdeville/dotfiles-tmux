ARG BASH_VERSION="2.5"
ARG FONTCONFIG_VERSION="2.15"
ARG GIT_VERSION="2.47"
ARG NEOVIM_VERSION="0.10"
ARG TMUX_VERSION="3.5"
ARG ZSH_VERSION="5.9"

# BUILDER
# -----------------------------------------------------------------------------
FROM alpine:3 AS build

ARG BASH_VERSION
ARG TMUX_VERSION
ARG GIT_VERSION

RUN apk update \
  && apk --no-cache add \
    "bash>=${BASH_VERSION}" \
    "git>=${GIT_VERSION}" \
    "tmux>=${TMUX_VERSION}" \
  && rm -rf /var/cache/apk/*

WORKDIR /usr/share/fonts
RUN  wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/FiraCode.zip \
  && unzip FiraCode.zip \
  && rm FiraCode.zip

WORKDIR /root
COPY \
  config/default.conf \
  config/plugins.conf \
  .config/tmux/
RUN git clone https://github.com/tmux-plugins/tpm ~/.cache/tmux/plugins/tpm \
  && ~/.cache/tmux/plugins/tpm/bin/install_plugins

# PRODUCTION
# -----------------------------------------------------------------------------
FROM alpine:3 AS prod

ARG BASH_VERSION
ARG FONTCONFIG_VERSION
ARG GIT_VERSION
ARG NEOVIM_VERSION
ARG TMUX_VERSION
ARG ZSH_VERSION

ENV LANG="C.UTF-8" \
    LC_ALL="C.UTF-8"

RUN apk update \
  && apk --no-cache add \
    "bash>=${BASH_VERSION}" \
    "fontconfig>=${FONTCONFIG_VERSION}" \
    "git>=${GIT_VERSION}" \
    "tmux>=${TMUX_VERSION}" \
    "neovim>=${NEOVIM_VERSION}" \
    "zsh>=${ZSH_VERSION}" \
  && rm -rf /var/cache/apk/*

WORKDIR /usr/share/fonts
COPY --from=build /usr/share/fonts/ /usr/share/fonts
RUN fc-cache -fv \
  && sed -i "s|root:/bin/.*|root:/bin/zsh|" /etc/passwd

WORKDIR /root
RUN echo "alias -- vim=nvim" > .bashrc \
  &&  echo "alias -- vim=nvim" > .zshrc
# Copy plugins
COPY --from=build /root/.cache/tmux/plugins .cache/tmux/plugins
COPY config/custom.conf .local/share/tmux/tmux.conf
COPY plugins .config/tmux/plugins
# Copy configs
COPY \
  config/ \
  plugins \
  ./config/tmux/
