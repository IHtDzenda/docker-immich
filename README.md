<!-- DO NOT EDIT THIS FILE MANUALLY -->
<!-- Please read https://github.com/imagegenius/docker-immich/blob/main/.github/CONTRIBUTING.md -->

# [imagegenius/immich](https://github.com/imagegenius/docker-immich)

[![GitHub Release](https://img.shields.io/github/release/imagegenius/docker-immich.svg?color=007EC6&labelColor=555555&logoColor=ffffff&style=for-the-badge&logo=github)](https://github.com/imagegenius/docker-immich/releases)
[![GitHub Package Repository](https://shields.io/badge/GitHub%20Package-blue?logo=github&logoColor=ffffff&style=for-the-badge)](https://github.com/imagegenius/docker-immich/packages)
[![Jenkins Build](https://img.shields.io/jenkins/build?labelColor=555555&logoColor=ffffff&style=for-the-badge&jobUrl=https%3A%2F%2Fci.imagegenius.io%2Fjob%2FDocker-Pipeline-Builders%2Fjob%2Fdocker-immich%2Fjob%2Fmain%2F&logo=jenkins)](https://ci.imagegenius.io/job/Docker-Pipeline-Builders/job/docker-immich/job/main/)
[![IG CI](https://img.shields.io/badge/dynamic/yaml?color=007EC6&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=CI&query=CI&url=https%3A%2F%2Fci-tests.imagegenius.io%2Fimmich%2Flatest-main%2Fci-status.yml)](https://ci-tests.imagegenius.io/immich/latest-main/index.html)

Immich is a high performance self-hosted photo and video backup solution.

[![immich](https://raw.githubusercontent.com/immich-app/immich/main/design/immich-logo-inline-dark.png)](https://immich.app/)

## Supported Architectures

We use Docker manifest for cross-platform compatibility. More details can be found on [Docker's website](https://github.com/docker/distribution/blob/master/docs/spec/manifest-v2-2.md#manifest-list).

To obtain the appropriate image for your architecture, simply pull `ghcr.io/imagegenius/immich:latest`. Alternatively, you can also obtain specific architecture images by using tags.

This image supports the following architectures:

| Architecture | Available | Tag |
| :----: | :----: | ---- |
| x86-64 | ✅ | amd64-\<version tag\> |
| arm64 | ✅ | arm64v8-\<version tag\> |
| armhf | ❌ | |

## Version Tags

This image offers different versions via tags. Be cautious when using unstable or development tags, and read their descriptions carefully.

| Tag | Available | Description |
| :----: | :----: |--- |
| latest | ✅ | Latest Immich release with an Ubuntu base. |
| noml | ✅ | Latest Immich release with an Ubuntu base. Machine-learning is completely removed. |
| alpine | ✅ | Latest Immich release with an Alpine base. Machine-learning is completely removed, making it a very lightweight image (can have issues with RAW images). |

## Application Setup

Access the WebUI at `http://your-ip:8080`. Follow the setup wizard to configure Immich.

> [!IMPORTANT]
> **This image is not officially supported by the Immich team.**
> 
> Please read and accept the consiquences of using this heavily active (in development) project.
> - ⚠️ The project is under very active development.
> - ⚠️ Expect bugs and breaking changes.
> - ⚠️ Do not use the app as the only way to store your photos and videos.
> - ⚠️ Always follow 3-2-1 backup plan for your precious photos and videos!
> 
> as stated in the official [readme](https://github.com/immich-app/immich#disclaimer).

### Requirements

- **PostgreSQL**: Version 14, 15, or 16 with [pgvecto.rs](https://github.com/tensorchord/pgvecto.rs) setup externally.
- **Redis**: Setup externally or within the container using a docker mod.

#### Docker Mod for Redis

- Set `DOCKER_MODS=imagegenius/mods:universal-redis`
- Configure `REDIS_HOSTNAME` to `localhost`

#### SSL Connection for PostgreSQL

To use SSL, include a PostgreSQL URL in the `DB_URL` environment variable.

## Hardware Acceleration

### Intel Hardware Acceleration

To enable Intel Quicksync:

1. Ensure container access to `/dev/dri`.
2. Add `/dev/dri` to your Docker run command:

   ```bash
   docker run --device=/dev/dri:/dev/dri ...
   ```

> [!NOTE]
> GPU acceleration for Intel via OpenVINO is not yet available.

### Nvidia Hardware Acceleration

1. Install the Nvidia container runtime as per [these instructions](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html).

2. Create a new Docker container using the Nvidia runtime:

   - Use `--runtime=nvidia` and `NVIDIA_VISIBLE_DEVICES=all` in your Docker run command, or specify a particular GPU UUID instead of `all`.

   ```bash
   docker run --runtime=nvidia -e NVIDIA_VISIBLE_DEVICES=all
   ```

   - Alternatively, use `--gpus=all` to enable all GPUs.

   ```bash
   docker run --gpus=all ...
   ```

3. To enable GPU acceleration for machine learning, add `MACHINE_LEARNING_GPU_ACCELERATION=cuda`

## Importing Existing Libraries

- Mount the existing library folder to `/import`.
- Set `/import` (or `/import/<user>` for multiple users) as the external path in the administration settings.
- In account settings, add a new library with the path set to `/import` or `/import/<user>`.

## Usage

Example snippets to start creating a container:

### Docker Compose

```yaml
---
services:
  immich:
    image: ghcr.io/imagegenius/immich:latest
    container_name: immich
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      - DB_HOSTNAME=192.168.1.x
      - DB_USERNAME=postgres
      - DB_PASSWORD=postgres
      - DB_DATABASE_NAME=immich
      - REDIS_HOSTNAME=192.168.1.x
      - DB_PORT=5432 #optional
      - REDIS_PORT=6379 #optional
      - REDIS_PASSWORD= #optional
      - MACHINE_LEARNING_GPU_ACCELERATION= #optional
      - MACHINE_LEARNING_HOST=0.0.0.0 #optional
      - MACHINE_LEARNING_PORT=3003 #optional
      - MACHINE_LEARNING_WORKERS=1 #optional
      - MACHINE_LEARNING_WORKER_TIMEOUT=120 #optional
    volumes:
      - path_to_appdata:/config
      - path_to_photos:/photos
      - path_to_imports:/import:ro #optional
    ports:
      - 8080:8080
    restart: unless-stopped

# This container requires an external application to be run separately.
# By default, ports for the databases are opened, be careful when deploying it
# Redis:
  redis:
    image: redis
    ports:
      - 6379:6379
    container_name: redis
# PostgreSQL 14:
  postgres14:
    image: tensorchord/pgvecto-rs:pg14-v0.2.0
    ports:
      - 5432:5432
    container_name: postgres14
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: immich
    volumes:
      - path_to_postgres:/var/lib/postgresql/data

```

### Docker CLI ([Click here for more info](https://docs.docker.com/engine/reference/commandline/cli/))

```bash
docker run -d \
  --name=immich \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Etc/UTC \
  -e DB_HOSTNAME=192.168.1.x \
  -e DB_USERNAME=postgres \
  -e DB_PASSWORD=postgres \
  -e DB_DATABASE_NAME=immich \
  -e REDIS_HOSTNAME=192.168.1.x \
  -e DB_PORT=5432 `#optional` \
  -e REDIS_PORT=6379 `#optional` \
  -e REDIS_PASSWORD= `#optional` \
  -e MACHINE_LEARNING_GPU_ACCELERATION= `#optional` \
  -e MACHINE_LEARNING_HOST=0.0.0.0 `#optional` \
  -e MACHINE_LEARNING_PORT=3003 `#optional` \
  -e MACHINE_LEARNING_WORKERS=1 `#optional` \
  -e MACHINE_LEARNING_WORKER_TIMEOUT=120 `#optional` \
  -p 8080:8080 \
  -v path_to_appdata:/config \
  -v path_to_photos:/photos \
  -v path_to_imports:/import:ro `#optional` \
  --restart unless-stopped \
  ghcr.io/imagegenius/immich:latest

# This container requires an external application to be run separately.
# By default, ports for the databases are opened, be careful when deploying it
# Redis:
docker run -d \
  --name=redis \
  -p 6379:6379 \
  redis

# PostgreSQL 14:
docker run -d \
  --name=postgres14 \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=immich \
  -v path_to_postgres:/var/lib/postgresql/data \
  -p 5432:5432 \
  tensorchord/pgvecto-rs:pg14-v0.2.0

```

## Parameters

To configure the container, pass variables at runtime using the format `<external>:<internal>`. For instance, `-p 8080:80` exposes port `80` inside the container, making it accessible outside the container via the host's IP on port `8080`.

| Parameter | Function |
| :----: | --- |
| `-p 8080` | WebUI Port |
| `-e PUID=1000` | UID for permissions - see below for explanation |
| `-e PGID=1000` | GID for permissions - see below for explanation |
| `-e TZ=Etc/UTC` | Specify a timezone to use, see this [list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List). |
| `-e DB_HOSTNAME=192.168.1.x` | PostgreSQL Host |
| `-e DB_USERNAME=postgres` | PostgreSQL Username |
| `-e DB_PASSWORD=postgres` | PostgreSQL Password |
| `-e DB_DATABASE_NAME=immich` | PostgreSQL Database Name |
| `-e REDIS_HOSTNAME=192.168.1.x` | Redis Hostname |
| `-e DB_PORT=5432` | PostgreSQL Port |
| `-e REDIS_PORT=6379` | Redis Port |
| `-e REDIS_PASSWORD=` | Redis password |
| `-e MACHINE_LEARNING_GPU_ACCELERATION=` | Enable cuda acceleration by setting the value to 'cuda' |
| `-e MACHINE_LEARNING_HOST=0.0.0.0` | Immich machine-learning host |
| `-e MACHINE_LEARNING_PORT=3003` | Immich machine-learning port |
| `-e MACHINE_LEARNING_WORKERS=1` | Machine learning workers |
| `-e MACHINE_LEARNING_WORKER_TIMEOUT=120` | Machine learning worker timeout |
| `-v /config` | Contains machine learning models (~1.5GB with default models) |
| `-v /photos` | Contains all the photos uploaded to Immich |
| `-v /import:ro` | This folder will be periodically scanned, contents will be automatically imported into Immich |

## Umask for running applications

All of our images allow overriding the default umask setting for services started within the containers using the optional -e UMASK=022 option. Note that umask works differently than chmod and subtracts permissions based on its value, not adding. For more information, please refer to the Wikipedia article on umask [here](https://en.wikipedia.org/wiki/Umask).

## User / Group Identifiers

To avoid permissions issues when using volumes (`-v` flags) between the host OS and the container, you can specify the user (`PUID`) and group (`PGID`). Make sure that the volume directories on the host are owned by the same user you specify, and the issues will disappear.

Example: `PUID=1000` and `PGID=1000`. To find your PUID and PGID, run `id user`.

```bash
  $ id username
    uid=1000(dockeruser) gid=1000(dockergroup) groups=1000(dockergroup)
```


## Updating the Container

Most of our images are static, versioned, and require an image update and container recreation to update the app. We do not recommend or support updating apps inside the container. Check the [Application Setup](#application-setup) section for recommendations for the specific image.

Instructions for updating containers:

### Via Docker Compose

* Update all images: `docker-compose pull`
  * or update a single image: `docker-compose pull immich`
* Let compose update all containers as necessary: `docker-compose up -d`
  * or update a single container: `docker-compose up -d immich`
* You can also remove the old dangling images: `docker image prune`

### Via Docker Run

* Update the image: `docker pull ghcr.io/imagegenius/immich:latest`
* Stop the running container: `docker stop immich`
* Delete the container: `docker rm immich`
* Recreate a new container with the same docker run parameters as instructed above (if mapped correctly to a host folder, your `/config` folder and settings will be preserved)
* You can also remove the old dangling images: `docker image prune`

## Versions

* **22.01.24:** - support GPU acceleration with CUDA for machine-learning
* **23.12.23:** - move to using seperate immich baseimage
* **07.12.23:** - rebase to ubuntu mantic
* **07.12.23:** - remove typesense (no longer needed)
* **24.09.23:** - house cleaning
* **24.09.23:** - add vars for ml workers/timeout
* **29.07.23:** - remove cuda acceleration for machine-learning
* **23.05.23:** - rebase to ubuntu lunar and support cuda acceleration for machine-learning
* **22.05.23:** - deprecate postgresql docker mod
* **18.05.23:** - add support for facial recognition
* **07.05.23:** - remove unused `JWT_SECRET` env
* **13.04.23:** - add variables to disable typesense and machine learning
* **10.04.23:** - fix gunicorn
* **04.04.23:** - use environment variables to set location of the photos folder
* **09.04.23:** - Cache is downloaded to the host (/config/transformers)
* **01.04.23:** - remove unused Immich environment variables
* **21.03.23:** - Add service checks
* **05.03.23:** - add typesense
* **27.02.23:** - re-enable aarch64 with pre-release torch build
* **18.02.23:** - use machine-learning with python
* **11.02.23:** - use external app block
* **09.02.23:** - Use Immich environment variables for immich services instead of hosts file
* **09.02.23:** - execute CLI with the command immich
* **04.02.23:** - shrink image
* **26.01.23:** - add unraid migration to readme
* **26.01.23:** - use find to apply chown to /app, excluding node_modules
* **26.01.23:** - enable ci testing
* **24.01.23:** - fix services starting prematurely, causing permission errors.
* **23.01.23:** - add noml image to readme and add aarch64 image to readme, make github release stable
* **21.01.23:** - BREAKING: Redis is removed. Update missing param_env_vars & opt_param_env_vars for redis & postgres
* **02.01.23:** - Initial Release.
