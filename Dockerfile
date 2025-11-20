FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    MCP_TRANSPORT=streamable-http \
    MCP_HOST=0.0.0.0 \
    MCP_PORT=8000

RUN apt-get update && apt-get install -y --no-install-recommends ffmpeg && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY pyproject.toml README.md uv.lock* ./
COPY douyin_mcp_server ./douyin_mcp_server

RUN pip install --upgrade pip && pip install .

EXPOSE 8000

CMD ["python", "-m", "douyin_mcp_server.server"]