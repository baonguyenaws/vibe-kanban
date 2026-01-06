#!/bin/bash

IMAGE_NAME="liukunup/vibe-kanban:latest"
CONTAINER_NAME="vibe-kanban"

echo "Stopping and removing existing container..."
docker stop $CONTAINER_NAME 2>/dev/null
docker rm $CONTAINER_NAME 2>/dev/null

echo "Starting new container..."

docker run -d \
  --name $CONTAINER_NAME \
  --restart unless-stopped \
  -p 8080:8080 \
  -e TZ=Asia/Shanghai \
  -v vk-data:/root/.local/share/vibe-kanban \
  -v vk-bin:/root/.vibe-kanban \
  $IMAGE_NAME

  # --- 可选配置 (请手动添加到上面的命令中) ---

  # 1. AI API Keys:
  # -e OPENAI_API_KEY="sk-..." \
  # -e ANTHROPIC_API_KEY="sk-ant-..." \
  # -e GITHUB_TOKEN="ghp_..." \

  # 2. Git 用户配置:
  # -e GIT_AUTHOR_NAME="Your Name" \
  # -e GIT_AUTHOR_EMAIL="your@email.com" \

  # 3. 项目目录挂载 (macOS/Linux):
  # -v "${HOME}/Documents/projects:/projects" \

  # 4. SSH/Git/Copilot 配置:
  # -v "${HOME}/.ssh:/root/.ssh:ro" \
  # -v "${HOME}/.gitconfig:/root/.gitconfig:ro" \
  # -v "${HOME}/.config/gh:/root/.config/gh" \
  # -v "${HOME}/.copilot:/root/.copilot" \

echo "Done. Container $CONTAINER_NAME is running on port 8080."
