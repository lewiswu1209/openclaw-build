FROM ghcr.io/openclaw/openclaw:latest

USER root

# Install additional system packages needed by your skills or extensions.
# Example: docker build --build-arg OPENCLAW_IMAGE_APT_PACKAGES="python3 wget" .
# Legacy alias: OPENCLAW_DOCKER_APT_PACKAGES is still accepted as a fallback.
ARG OPENCLAW_IMAGE_APT_PACKAGES
ARG OPENCLAW_DOCKER_APT_PACKAGES=""
ENV PATH="/home/node/.local/bin:${PATH}"
RUN --mount=type=cache,id=openclaw-bookworm-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=openclaw-bookworm-apt-lists,target=/var/lib/apt,sharing=locked \
    packages="${OPENCLAW_IMAGE_APT_PACKAGES:-$OPENCLAW_DOCKER_APT_PACKAGES}"; \
    if [ -n "$packages" ]; then \
      apt-get update && \
      DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends $packages; \
    fi

# Install additional Python packages needed by your plugins or skills.
# Example: docker build --build-arg OPENCLAW_IMAGE_PIP_PACKAGES="requests humanize" .
ARG OPENCLAW_IMAGE_PIP_PACKAGES=""
RUN --mount=type=cache,id=openclaw-bookworm-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=openclaw-bookworm-apt-lists,target=/var/lib/apt,sharing=locked \
    if [ -n "$OPENCLAW_IMAGE_PIP_PACKAGES" ]; then \
      if ! python3 -m pip --version >/dev/null 2>&1; then \
        apt-get update && \
        DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends python3-pip; \
      fi && \
      python3 -m pip install --no-cache-dir --break-system-packages $OPENCLAW_IMAGE_PIP_PACKAGES; \
    fi

# install additional npm packages needed by your plugins or skills.
# Example: docker build --build-arg OPENCLAW_IMAGE_NPM_PACKAGES="opencode-ai" .
ARG OPENCLAW_IMAGE_NPM_PACKAGES=""
RUN if [ -n "$OPENCLAW_IMAGE_NPM_PACKAGES" ]; then \
      npm install -g ${OPENCLAW_IMAGE_NPM_PACKAGES} \
      && npm cache clean --force ;\
    fi

# Security hardening: Run as non-root user
# The node:24-bookworm image includes a 'node' user (uid 1000)
# This reduces the attack surface by preventing container escape via root privileges
USER node
