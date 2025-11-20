# 抖音无水印视频文本提取 MCP 服务器

[![PyPI version](https://badge.fury.io/py/douyin-mcp-server.svg)](https://badge.fury.io/py/douyin-mcp-server)
[![Python version](https://img.shields.io/pypi/pyversions/douyin-mcp-server.svg)](https://pypi.org/project/douyin-mcp-server/)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

一个基于 Model Context Protocol (MCP) 的服务器，可以从抖音分享链接下载无水印视频，提取音频并转换为文本。

<a href="https://glama.ai/mcp/servers/@yzfly/douyin-mcp-server">
  <img width="380" height="200" src="https://glama.ai/mcp/servers/@yzfly/douyin-mcp-server/badge" alt="douyin-mcp-server MCP server" />
</a>

## 📋 项目声明

**官方文档地址：** https://github.com/yzfly/douyin-mcp-server

请以本项目的 [README.md](https://github.com/yzfly/douyin-mcp-server/blob/main/README.md) 文件为准，了解项目的功能特性、使用方法、API 配置说明等详细信息。

**重要提醒：** 第三方平台如因自身 MCP Server 功能支持度限制而无法正常使用，请联系相应平台方。本项目不提供任何形式的技术支持或保证，用户需自行承担使用本项目可能产生的任何损失或损害。

**法律声明：**
1. 本项目基于 Apache 2.0 协议发布
2. 本项目仅供学习和研究使用，不得用于任何违法或违规目的
3. 本项目的使用必须遵守相关法律法规
4. 本项目的作者和贡献者不对项目的任何部分承担法律责任

## ✨ 功能特性

- 🎵 **无水印视频获取** - 从抖音分享链接获取高质量无水印视频
- 🎧 **智能音频提取** - 自动从视频中提取音频内容
- 📝 **AI 文本识别** - 使用先进的语音识别技术提取文本内容
- 🧹 **自动清理** - 智能清理处理过程中的临时文件
- 🔧 **灵活配置** - 支持自定义 API 配置，默认使用 [阿里云百炼 API](https://help.aliyun.com/zh/model-studio/get-api-key?)

## 🚀 快速开始

### 步骤 1：获取 API 密钥

前往 [阿里云百炼 API](https://help.aliyun.com/zh/model-studio/get-api-key?) 获取您的 `DASHSCOPE_API_KEY`：

![获取阿里云百炼API](https://files.mdnice.com/user/43439/36e658be-1ccf-41dd-87cf-d43fefde5c4e.png)

### 步骤 2：配置环境变量

在 Claude Desktop、Cherry Studio 等支持 MCP Server 的应用配置文件中添加以下配置：

```json
{
  "mcpServers": {
    "douyin-mcp": {
      "command": "uvx",
      "args": ["douyin-mcp-server"],
      "env": {
        "DASHSCOPE_API_KEY": "sk-xxxx"
      }
    }
  }
}
```

### 步骤 3：开始使用（本地/uv 运行）

配置完成后，您就可以在支持的应用中正常调用 MCP 工具了。

### 使用 Docker 运行

```bash
# 构建镜像
docker build -t douyin-mcp-server:local .

# 运行（仅下载链接工具，不需要密钥）
docker run --rm -p 8000:8000 douyin-mcp-server:local

# 运行（启用文本提取，需要阿里云百炼密钥）
docker run --rm -p 8000:8000 \
  -e DASHSCOPE_API_KEY="你的API密钥" \
  douyin-mcp-server:local
```

服务端点：`http://localhost:8000/mcp`

### 使用 Docker Compose 运行

```bash
# 设置环境变量（macOS/Linux）
export DASHSCOPE_API_KEY="你的API密钥"

# 启动
docker compose up -d

# 查看日志
docker compose logs -f

# 停止
docker compose down
```

可通过修改 `docker-compose.yml` 调整端口或环境变量：

```yaml
services:
  douyin-mcp:
    build: .
    environment:
      MCP_TRANSPORT: "streamable-http"
      MCP_HOST: "0.0.0.0"
      MCP_PORT: "8000"
      DASHSCOPE_API_KEY: ${DASHSCOPE_API_KEY:-}
      MCP_AUTH_TYPE: ${MCP_AUTH_TYPE:-bearer}
      MCP_AUTH_TOKEN: ${MCP_AUTH_TOKEN:-}
      MCP_AUTH_BASIC_USER: ${MCP_AUTH_BASIC_USER:-}
      MCP_AUTH_BASIC_PASS: ${MCP_AUTH_BASIC_PASS:-}
    ports:
      - "8000:8000"
```

说明：
- Docker 镜像中已安装 `ffmpeg`，无需额外配置
- 网络传输默认使用 Streamable HTTP，容器绑定 `0.0.0.0:8000`
- 如果只使用下载链接工具，可以不设置 `DASHSCOPE_API_KEY`

### 启用鉴权（HTTP/SSE）

服务支持通过环境变量启用请求头鉴权：

- `MCP_AUTH_TYPE`: `bearer` 或 `basic`，默认 `bearer`
- `MCP_AUTH_TOKEN`: 当 `bearer` 模式下为必填
- `MCP_AUTH_BASIC_USER` / `MCP_AUTH_BASIC_PASS`: 当 `basic` 模式下为必填

请求头示例：

- Bearer: `Authorization: Bearer <token>`
- Basic: `Authorization: Basic <base64(user:pass)>`

校验覆盖路径：`/mcp`、`/sse`、`/messages/`

### 本地调试（Python 直接启动）

```bash
# 创建并激活虚拟环境
python3 -m venv .venv
source .venv/bin/activate

# 安装依赖
pip install -e .

# 可选：启用鉴权（Bearer）
export MCP_AUTH_TYPE=bearer
export MCP_AUTH_TOKEN=dev-token

# 启动网络模式（Streamable HTTP，端口 8000）
python -m douyin_mcp_server.server --transport streamable-http --port 8000

# 访问端点
# http://localhost:8000/mcp
```

### 国内镜像加速（Docker 构建）

```bash
# 默认使用阿里云镜像
docker build -t douyin-mcp-server:local .

# 指定清华镜像（APT/PyPI）
docker build \
  --build-arg APT_MIRROR=mirrors.tuna.tsinghua.edu.cn \
  --build-arg PIP_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple \
  -t douyin-mcp-server:local .
```

## ⚙️ API 配置说明

### 当前版本（>= 1.2.0）

最新版本默认使用阿里云百炼 API，具有以下优势：
- ✅ 识别效果更好
- ✅ 处理速度更快
- ✅ 本地资源消耗更小

**配置步骤：**
1. 前往 [阿里云百炼](https://help.aliyun.com/zh/model-studio/get-api-key?) 开通 API 服务
2. 获取 API Key 并配置到环境变量 `DASHSCOPE_API_KEY` 中

### 旧版本兼容（<= 1.1.0）

如果您需要使用旧版本，请使用以下配置：

```json
{
  "mcpServers": {
    "douyin-mcp": {
      "command": "uvx",
      "args": ["douyin-mcp-server@1.1.0"],
      "env": {
        "DOUYIN_API_KEY": "your-api-key-here"
      }
    }
  }
}
```

**注意：** 旧版本使用硅基流动 API，需要在 [硅基流动](https://cloud.siliconflow.cn/i/TxUlXG3u) 注册账号并获取 API Key。

📖 [1.1.0 版本文档](https://pypi.org/project/douyin-mcp-server/1.1.0/)

## 🛠️ 工具说明

### `get_douyin_download_link`

获取抖音视频的无水印下载链接。

**参数：**
- `share_link` (string): 抖音分享链接或包含链接的文本

**返回：**
- JSON 格式的下载链接和视频信息

**特点：** 无需 API 密钥即可使用

### `extract_douyin_text`

完整的文本提取工具，一站式完成视频到文本的转换。

**处理流程：**
1. 解析抖音分享链接
2. 直接使用视频 URL 进行语音识别
3. 返回提取的文本内容

**参数：**
- `share_link` (string): 抖音分享链接或包含链接的文本
- `model` (string, 可选): 语音识别模型，默认使用 `paraformer-v2`

**环境变量要求：**
- `DASHSCOPE_API_KEY`: 阿里云百炼 API 密钥（必需）

### `parse_douyin_video_info`

轻量级视频信息解析工具。

**参数：**
- `share_link` (string): 抖音分享链接

**特点：** 仅解析视频基本信息，不下载视频文件

### 资源访问

- `douyin://video/{video_id}`: 通过视频 ID 获取详细信息

## 📦 系统要求

### 运行环境
- **Python**: 3.10 或更高版本

### 依赖库
- `requests` - HTTP 请求处理
- `ffmpeg-python` - 音视频处理
- `tqdm` - 进度条显示
- `mcp` - Model Context Protocol 支持
- `dashscope` - 阿里云百炼 API 客户端

## ⚠️ 注意事项

- 🔑 **API 密钥必需**：文本提取功能需要有效的阿里云百炼 API 密钥
- 🆓 **部分功能免费**：获取下载链接功能无需 API 密钥
- 📱 **格式支持**：支持大部分抖音视频格式
- 🚀 **性能优化**：使用阿里云百炼 API 获得更快更准确的识别效果

## 🔧 开发指南

### 本地开发环境搭建

```bash
# 克隆项目
git clone https://github.com/yzfly/douyin-mcp-server.git
cd douyin-mcp-server

# 安装依赖（开发模式）
pip install -e .
```

### 运行测试

```bash
# 启动服务器进行测试（STDIO）
python -m douyin_mcp_server.server

# 启动网络模式（Streamable HTTP，端口 8000）
python -m douyin_mcp_server.server --transport streamable-http --port 8000
```

### Claude Desktop 本地开发配置

在 Claude Desktop 配置文件中添加本地开发配置：

```json
{
  "mcpServers": {
    "douyin-mcp": {
      "command": "uv",
      "args": [
        "run",
        "--directory",
        "/path/to/your/douyin-mcp-server",
        "python",
        "-m",
        "douyin_mcp_server"
      ],
      "env": {
        "DASHSCOPE_API_KEY": "your-api-key-here"
      }
    }
  }
}
```

## ⚠️ 免责声明

### 使用风险
- 使用者对本项目的使用完全自主决定，并自行承担所有风险
- 作者对使用者因使用本项目而产生的任何损失、责任或风险概不负责

### 代码质量
- 本项目基于现有知识和技术开发，作者努力确保代码的正确性和安全性
- 但不保证代码完全没有错误或缺陷，使用者需自行评估和测试

### 第三方依赖
- 本项目依赖的第三方库、插件或服务遵循各自的开源或商业许可
- 使用者需自行查阅并遵守相应协议
- 作者不对第三方组件的稳定性、安全性及合规性承担责任

### 法律合规
- 使用者必须自行研究相关法律法规，确保使用行为合法合规
- 任何违反法律法规导致的法律责任和风险，均由使用者自行承担
- 禁止使用本工具从事任何侵犯知识产权的行为
- 开发者不参与、不支持、不认可任何非法内容的获取或分发

### 数据处理
- 本项目不对使用者的数据收集、存储、传输等处理活动的合规性承担责任
- 使用者应自行遵守相关法律法规，确保数据处理行为合法正当

### 责任限制
- 使用者不得将项目作者、贡献者或相关方与使用行为联系起来
- 不得要求作者对使用项目产生的任何损失或损害负责
- 基于本项目的二次开发、修改或编译程序与原作者无关

### 知识产权
- 本项目不授予使用者任何专利许可
- 若使用本项目导致专利纠纷或侵权，使用者自行承担全部风险和责任
- 未经书面授权，不得用于商业宣传、推广或再授权

### 服务终止
- 作者保留随时终止向违反声明的使用者提供服务的权利
- 可能要求违规使用者销毁已获取的代码及衍生作品
- 作者保留在不另行通知的情况下更新本声明的权利

**⚠️ 重要提醒：在使用本项目前，请认真阅读并完全理解上述免责声明。如有疑问或不同意任何条款，请勿使用本项目。继续使用即视为完全接受上述声明并自愿承担所有风险和后果。**

## 📄 许可证

Apache License 2.0

## 👨‍💻 作者

- **yzfly** - [yz.liu.me@gmail.com](mailto:yz.liu.me@gmail.com)
- GitHub: [https://github.com/yzfly](https://github.com/yzfly)

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！我们期待您的参与和贡献。

## 📝 更新日志

### v1.2.0 (最新)
- 🚀 **性能提升**：更快、更准确的视频文案提取
- 🔄 **API 升级**：切换到阿里云百炼 API，显著提升识别准确率
- 🔧 **配置更新**：环境变量从 `DOUYIN_API_KEY` 更新为 `DASHSCOPE_API_KEY`

### v1.1.0
- 🐛 **问题修复**：修复提取视频时文件名过长导致的错误

### v1.0.0
- 🎉 **首次发布**：初始版本
- ✨ **核心功能**：支持抖音视频文本提取
- 🔗 **链接获取**：支持获取无水印视频下载链接
- 🔐 **环境配置**：从环境变量读取 API 密钥
- 🧹 **自动清理**：自动清理临时文件
- ⚙️ **灵活配置**：支持自定义 API 配置