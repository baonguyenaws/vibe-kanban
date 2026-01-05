# Makefile for managing the Vibe Kanban Docker container

IMAGE_NAME = vibe-kanban:dev
CONTAINER_NAME = vibe-kanban-dev
PORT = 8080

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

.PHONY: build
build:
	docker build -t $(IMAGE_NAME) .

.PHONY: run
run: clean
	@echo "Starting container $(CONTAINER_NAME)..."
	docker run -d \
		--name $(CONTAINER_NAME) \
		--restart unless-stopped \
		-p $(PORT):8080 \
		-e TZ=Asia/Shanghai \
		-v vibe-kanban-npm-cache:/root/.npm \
		$(IMAGE_NAME)
	@echo "Container started on http://localhost:$(PORT)"

.PHONY: clean
clean: stop
	@if [ -n "$$(docker ps -aq -f name=^/$(CONTAINER_NAME)$$)" ]; then \
		echo "Removing container..."; \
		docker rm $(CONTAINER_NAME); \
		echo "Removing volume..."; \
		docker volume rm vibe-kanban-npm-cache || true; \
	else \
		echo "Container $(CONTAINER_NAME) does not exist."; \
	fi

.PHONY: stop
stop:
	@if [ -n "$$(docker ps -q -f name=^/$(CONTAINER_NAME)$$)" ]; then \
		echo "Stopping container..."; \
		docker stop $(CONTAINER_NAME); \
	else \
		echo "Container $(CONTAINER_NAME) is not running."; \
	fi

.PHONY: logs
logs:
	@if [ -n "$$(docker ps -aq -f name=^/$(CONTAINER_NAME)$$)" ]; then \
		docker logs -f $(CONTAINER_NAME); \
	else \
		echo "Container $(CONTAINER_NAME) does not exist."; \
	fi

.PHONY: shell
shell:
	@if [ -n "$$(docker ps -q -f name=^/$(CONTAINER_NAME)$$)" ]; then \
		docker exec -it $(CONTAINER_NAME) /bin/bash; \
	else \
		echo "Container $(CONTAINER_NAME) is not running."; \
	fi
