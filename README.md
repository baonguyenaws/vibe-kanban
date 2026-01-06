# Vibe Kanban in Docker

这个项目提供了一个便捷的 Docker 环境来运行 [Vibe Kanban](https://www.vibekanban.com/)。你可以直接使用预构建的镜像，也可以自己构建。

## 前置条件

- Docker
- Docker Compose

## 快速开始

1.  **克隆或下载本项目**

2.  **配置项目路径**

    打开 `docker-compose.yml`，找到 `volumes` 部分，根据你的操作系统取消注释并修改项目挂载路径：

    ```yaml
    volumes:
      # MacOS / Linux
      - ${HOME}/Documents/projects:/projects
      # Windows
      # - C:/Users/YourUserName/Documents/projects:/projects
    ```

3.  **启动容器**

    ```bash
    # 这将自动拉取 liukunup/vibe-kanban:latest 镜像并启动
    docker-compose up -d
    ```

4.  **访问 Vibe Kanban**

    打开浏览器访问 [http://localhost:8080](http://localhost:8080)。

## 配置说明

### 挂载项目目录

你需要将宿主机的代码目录挂载到容器内的 `/projects`，这样 Vibe Kanban 才能扫描和管理你的 Git 项目。
请参考 `docker-compose.yml` 中的注释进行配置。

### Git 和 GitHub 认证

为了让 Vibe Kanban 能够进行 Git 操作和 GitHub 集成，你可以配置以下挂载（在 `docker-compose.yml` 中取消注释）：

- **SSH 密钥**: `${HOME}/.ssh` -> `/root/.ssh` (只读) - 用于 SSH 协议克隆/推送
- **Git 配置**: `${HOME}/.gitconfig` -> `/root/.gitconfig` (只读) - 用于共享 Git 用户名/邮箱配置
- **GitHub CLI 配置**: `${HOME}/.config/gh` -> `/root/.config/gh` - 用于 GitHub 登录状态
- **GitHub Copilot 配置**: `${HOME}/.copilot` -> `/root/.copilot` (可能因系统而异) - 用于 Copilot 认证

这意味着如果你在宿主机上已经配置好了 Git 和 GitHub CLI (`gh auth login`)，容器内将自动继承这些认证状态。

### Docker Socket (可选)

如果你希望在 Vibe Kanban 中使用 Docker 功能（例如管理其他容器），可以挂载 Docker Socket：
- `/var/run/docker.sock` -> `/var/run/docker.sock`

### 数据持久化

容器使用两个 Docker 命名卷来持久化数据，即使删除容器数据也不会丢失：
- `vk-data`: 挂载到 `/root/.local/share/vibe-kanban` (应用数据)
- `vk-bin`: 挂载到 `/root/.vibe-kanban` (二进制文件缓存)

### 端口

默认使用端口 `8080`。如果需要更改，请修改 `docker-compose.yml` 中的 `ports` 部分。

### 环境变量与 API Keys

你可以在 `docker-compose.yml` 中配置环境变量，例如设置时区或 AI 服务的 API Key：

```yaml
environment:
  - TZ=Asia/Shanghai

  # AI 模型 API Key
  # - OPENAI_API_KEY=sk-...
  # - ANTHROPIC_API_KEY=sk-ant-...
  # - GEMINI_API_KEY=...
  # - GITHUB_TOKEN=ghp_...

  # Git 用户配置 (如果没有挂载 .gitconfig)
  # - GIT_AUTHOR_NAME=Your Name
  # - GIT_AUTHOR_EMAIL=your@email.com
  # - GIT_COMMITTER_NAME=Your Name
  # - GIT_COMMITTER_EMAIL=your@email.com
```

## 常见问题

### 权限问题

如果遇到文件权限问题，可能需要调整容器内的用户 ID 以匹配宿主机用户。目前容器默认以 `root` 运行，通常可以访问挂载的文件，但创建的文件可能属于 `root`。

### 无法找到项目

确保你挂载的目录中包含 `.git` 文件夹的项目，并且 Vibe Kanban 有权限访问它们。
