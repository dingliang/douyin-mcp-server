FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    MCP_TRANSPORT=streamable-http \
    MCP_HOST=0.0.0.0 \
    MCP_PORT=8000

# 国内镜像加速（可通过 build-arg 覆盖）
ARG APT_MIRROR=mirrors.aliyun.com
ARG PIP_INDEX_URL=https://mirrors.aliyun.com/pypi/simple

RUN set -eux; \
    codename="$(grep VERSION_CODENAME /etc/os-release | cut -d= -f2)"; \
    if [ -f /etc/apt/sources.list.d/debian.sources ]; then rm /etc/apt/sources.list.d/debian.sources; fi; \
    echo "deb http://${APT_MIRROR}/debian ${codename} main contrib non-free" > /etc/apt/sources.list; \
    echo "deb http://${APT_MIRROR}/debian ${codename}-updates main contrib non-free" >> /etc/apt/sources.list; \
    echo "deb http://${APT_MIRROR}/debian ${codename}-backports main contrib non-free" >> /etc/apt/sources.list; \
    echo "deb http://${APT_MIRROR}/debian-security ${codename}-security main contrib non-free" >> /etc/apt/sources.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends ffmpeg; \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY pyproject.toml README.md uv.lock* ./
COPY douyin_mcp_server ./douyin_mcp_server

RUN pip install --upgrade pip -i ${PIP_INDEX_URL} && pip install . -i ${PIP_INDEX_URL}

EXPOSE 8000

CMD ["python", "-m", "douyin_mcp_server.server"]