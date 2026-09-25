# openclaw-build

在 [OpenClaw](https://github.com/openclaw/openclaw) 预构建镜像基础上，快速添加 `apt`/`pip`/`npm` 依赖构建自定义镜像 —— 避免从头构建带来的高内存、长耗时问题，同时解决预构建镜像缺少 skill/plugin 所需程序的痛点。

## 核心特性

- **三大包管理器全支持**：`apt` (系统包)、`pip` (Python)、`npm` (Node.js)
- **BuildKit 缓存加速**：`apt` 下载缓存复用，二次构建秒级完成
- **安全加固**：最终以非 root 用户 (`node:1000`) 运行，降低攻击面
- **版本锁定**：原生支持 `package=version` / `package==version` 语法
- **零配置启动**：仅需设置环境变量即可构建

## 前置要求

- Docker 20.10+ 且启用 **BuildKit** (`DOCKER_BUILDKIT=1` 或 `docker buildx`)
- 可访问 `ghcr.io/openclaw/openclaw:latest-browser` 基础镜像

## 快速开始

```bash
# 1. 克隆仓库
git clone https://github.com/lewiswu1209/openclaw-build.git
cd openclaw-build

# 2. 设置必需环境变量
export OPENCLAW_IMAGE=my-openclaw:latest

# 3. 可选：添加需要的包（空格分隔，支持版本锁定）
export OPENCLAW_IMAGE_APT_PACKAGES="python3 wget curl"
export OPENCLAW_IMAGE_PIP_PACKAGES="requests==2.31.0 humanize"
export OPENCLAW_IMAGE_NPM_PACKAGES="opencode-ai @modelcontextprotocol/sdk"

# 4. 赋予执行权限并构建
chmod +x openclaw-build.sh
./openclaw-build.sh
```

### 环境变量详解

| 变量 | 必需 | 说明 | 示例 |
|------|------|------|------|
| `OPENCLAW_IMAGE` | ✅ | 输出镜像标签（`registry/name:tag`） | `my-openclaw:latest` |
| `OPENCLAW_IMAGE_APT_PACKAGES` | ❌ | apt 包列表（空格分隔） | `python3 wget curl` |
| `OPENCLAW_IMAGE_PIP_PACKAGES` | ❌ | pip 包列表（支持 `==` 锁版本） | `requests==2.31.0 humanize` |
| `OPENCLAW_IMAGE_NPM_PACKAGES` | ❌ | npm 全局包列表 | `opencode-ai @modelcontextprotocol/sdk` |
| `OPENCLAW_DOCKER_APT_PACKAGES` | ❌ | 兼容旧版别名，优先级低于 `OPENCLAW_IMAGE_APT_PACKAGES` | 同上 |

## 构建后使用 ⭐

镜像构建完成后，**必须运行 Openclaw 原项目的离线安装脚本**完成最终部署：

```bash
  scripts/docker/setup.sh --offline
```

## 文件结构

```
openclaw-build/
├── Dockerfile           # 多阶段构建定义（基于 ghcr.io/openclaw/openclaw:latest-browser）
├── openclaw-build.sh    # 构建入口脚本（透传环境变量为 build-arg）
└── README.md
```

---

**相关链接**
- [OpenClaw 官方仓库](https://github.com/openclaw/openclaw)
- [OpenClaw Docker 安装文档](https://docs.openclaw.ai/install/docker)
- [本项目 GitHub](https://github.com/lewiswu1209/openclaw-build)