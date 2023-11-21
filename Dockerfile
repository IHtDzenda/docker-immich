# syntax=docker/dockerfile:1

FROM ghcr.io/imagegenius/baseimage-alpine:edge

# set version label
ARG BUILD_DATE
ARG VERSION
ARG IMMICH_VERSION
LABEL build_version="ImageGenius Version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="hydazz, martabal"

# environment settings
ENV \
  IMMICH_MACHINE_LEARNING_ENABLED="false" \
  IMMICH_MEDIA_LOCATION="/photos" \
  REVERSE_GEOCODING_DUMP_DIRECTORY="/config/.reverse-geocoding-dump/" \
  SERVER_PORT="8080"

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    g++ \  
    make \
    vips-dev && \  
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    ffmpeg \
    imagemagick-dev \
    libraw-dev \
    nodejs \
    npm \
    openssl \
    perl \
    vips \
    vips-cpp \
    vips-heif \
    vips-jxl \
    vips-magick && \
  echo "**** download immich ****" && \
  mkdir -p \
    /tmp/immich && \
  if [ -z ${IMMICH_VERSION} ]; then \
    IMMICH_VERSION=$(curl -sL https://api.github.com/repos/immich-app/immich/releases/latest | \
      jq -r '.tag_name'); \
  fi && \
  curl -o \
    /tmp/immich.tar.gz -L \
    "https://github.com/immich-app/immich/archive/${IMMICH_VERSION}.tar.gz" && \
  tar xf \
    /tmp/immich.tar.gz -C \
    /tmp/immich --strip-components=1 && \
  echo "**** build server ****" && \
  cd /tmp/immich/server && \
  npm ci && \
  npm run build && \
  npm prune --omit=dev --omit=optional && \
  npm link && \
  npm cache clean --force && \
  mkdir -p \
    /app/immich/server && \
  cp -a \
    package.json \
    package-lock.json \
    node_modules \
    dist \
    /app/immich/server && \
  echo "**** build web ****" && \
  cd /tmp/immich/web && \
  npm ci && \
  npm run build && \
  mkdir -p \
    /app/immich/server/www && \
  cp -a \
    build/* \
    static \
    /app/immich/server/www  && \
  echo "**** install immich cli (immich upload) ****" && \
    npm install -g --prefix /tmp/cli @immich/cli && \
    mv /tmp/cli/lib/node_modules/@immich/cli /app/cli && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /tmp/* \
    /root/.cache \
    /root/.npm

# environment settings
ENV NODE_ENV="production"

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 8080
VOLUME /config /uploads
