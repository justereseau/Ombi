FROM ubuntu:latest

# Read the release version from the build args
ARG RELEASE_TAG

LABEL build="JusteReseau - Version: ${RELEASE_TAG}"
LABEL org.opencontainers.image.description="This is a docker image for Ombi, that work with Kubernetes security baselines."
LABEL org.opencontainers.image.licenses="WTFPL"
LABEL org.opencontainers.image.source="https://github.com/justereseau/Ombi"
LABEL maintainer="JusteSonic"

# Install requirements
RUN apt-get update && apt-get upgrade -y && apt-get install -y wget libicu70 \
  && apt-get autoremove -y && apt clean && rm -rf /var/lib/apt/lists/*

# Download and install the binary
RUN mkdir /opt/ombi \
  && wget -O /tmp/binary.tar.gz https://github.com/Ombi-app/Ombi/releases/download/v${RELEASE_TAG}/linux-x64.tar.gz \
  && tar -xvzf /tmp/binary.tar.gz -C /opt/ombi \
  && rm -rf /tmp/*

# Ensure the Servarr user and group exists and set the permissions
RUN adduser --system --uid 1000 --group --disabled-password servarr \
  && mkdir -p /config && chown -R servarr:servarr /config \
  && chown -R servarr:servarr /opt/ombi

# Set the user
USER servarr

# Expose the port
EXPOSE 3579

WORKDIR /opt/ombi

# Set the command
CMD ["/opt/ombi/Ombi", "--storage=/config", "--host=http://*:3579"]
