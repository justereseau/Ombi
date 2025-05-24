FROM alpine:latest AS builder

# Read the release version from the build args
ARG RELEASE_TAG

# Set the working directory
WORKDIR /build

# Get the download URL
RUN case $(uname -m) in \
  x86_64) \
  echo https://github.com/Ombi-app/Ombi/releases/download/v${RELEASE_TAG}/linux-x64.tar.gz > /tmp/download_url \
  ;; \
  aarch64) \
  echo https://github.com/Ombi-app/Ombi/releases/download/v${RELEASE_TAG}/linux-arm64.tar.gz > /tmp/download_url \
  ;; \
  *) \
  echo "Unsupported architecture > $(uname -m)" \
  exit 1 \
  ;; \
  esac

# Download and extract the binary
RUN wget -O /tmp/binary.tar.gz $(cat /tmp/download_url) && \
  tar -xvzf /tmp/binary.tar.gz -C /build --strip-components=1

FROM ubuntu:22.04

# Read the release version from the build args
ARG RELEASE_TAG

LABEL build="JusteReseau - Version: ${RELEASE_TAG}"
LABEL org.opencontainers.image.description="This is a docker image for Ombi, that work with Kubernetes security baselines."
LABEL org.opencontainers.image.licenses="WTFPL"
LABEL org.opencontainers.image.source="https://github.com/justereseau/Ombi"
LABEL maintainer="JusteSonic"

COPY --from=builder /build /opt/ombi

# Install requirements
RUN apt-get update && apt-get upgrade -y && apt-get install -y libicu70 \
  && apt-get autoremove -y && apt clean && rm -rf /var/lib/apt/lists/*

# Ensure the Servarr user and group exists and set the permissions
RUN adduser --system --uid 1000 --group --disabled-password servarr \
  && mkdir -p /config && chown -R servarr:servarr /config \
  && chown -R servarr:servarr /opt/ombi

# Set the user
USER servarr

# Expose the port
EXPOSE 8989

WORKDIR /opt/ombi

# Set the command
CMD ["/opt/ombi/Ombi", "--storage=/config", "--host=http://*:3579"]
