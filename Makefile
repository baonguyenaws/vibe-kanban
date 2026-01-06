# Makefile for managing the Vibe Kanban Docker container

IMAGE_NAME = vibe-kanban:dev
CONTAINER_NAME = vibe-kanban-dev
PORT = 8080

# 显示帮助信息
.PHONY: help
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  build       Build the Docker image"
	@echo "  run         Run the container (stops existing one first)"
	@echo "  stop        Stop the running container"
	@echo "  clean       Stop and remove the container"
	@echo "  logs        Follow container logs"
	@echo "  shell       Enter the container shell"

# 构建镜像
.PHONY: build
build:
	@echo "Select Dockerfile to build:"
	@echo "1) Dockerfile.node"
	@echo "2) Dockerfile.ubuntu"
	@read -p "Enter choice [1-2]: " choice; \
	if [ "$$choice" = "1" ]; then \
		DOCKERFILE="Dockerfile.node"; \
	elif [ "$$choice" = "2" ]; then \
		DOCKERFILE="Dockerfile.ubuntu"; \
	else \
		echo "Invalid choice"; \
		exit 1; \
	fi; \
	echo "Building using $$DOCKERFILE..."; \
	docker build -f $$DOCKERFILE -t $(IMAGE_NAME) .

# 运行容器
.PHONY: run
run: clean
	@echo "Starting container $(CONTAINER_NAME)..."
	docker run -d \
		--name $(CONTAINER_NAME) \
		--restart unless-stopped \
		-p $(PORT):8080 \
		-e TZ=Asia/Shanghai \
		-v cache-local-share:/root/.local/share/vibe-kanban \
		-v cache-vibe-kanban:/root/.vibe-kanban \
		-v cache-copilot:/root/.copilot \
		$(IMAGE_NAME)
	@echo "Container started on http://127.0.0.1:$(PORT)"

# 停止并移除容器及相关卷
.PHONY: clean
clean: stop
	@if [ -n "$$(docker ps -aq -f name=^/$(CONTAINER_NAME)$$)" ]; then \
		echo "Removing container..."; \
		docker rm $(CONTAINER_NAME); \
		echo "Removing volume..."; \
		docker volume rm cache-local-share || true; \
		docker volume rm cache-vibe-kanban || true; \
		docker volume rm cache-copilot || true; \
	else \
		echo "Container $(CONTAINER_NAME) does not exist."; \
	fi

# 停止正在运行的容器
.PHONY: stop
stop:
	@if [ -n "$$(docker ps -q -f name=^/$(CONTAINER_NAME)$$)" ]; then \
		echo "Stopping container..."; \
		docker stop $(CONTAINER_NAME); \
	else \
		echo "Container $(CONTAINER_NAME) is not running."; \
	fi

# 查看容器日志
.PHONY: logs
logs:
	@if [ -n "$$(docker ps -aq -f name=^/$(CONTAINER_NAME)$$)" ]; then \
		docker logs -f $(CONTAINER_NAME); \
	else \
		echo "Container $(CONTAINER_NAME) does not exist."; \
	fi

# 进入容器的 shell 环境
.PHONY: shell
shell:
	@if [ -n "$$(docker ps -q -f name=^/$(CONTAINER_NAME)$$)" ]; then \
		docker exec -it $(CONTAINER_NAME) /bin/bash; \
	else \
		echo "Container $(CONTAINER_NAME) is not running."; \
	fi
