# Makefile for Maktabati documentation site
# Supports common development tasks with intelligent checks and interactive server management
.PHONY: help install dev build preview test e2e e2e-ui e2e-report clean server-check server-kill

help:
	@echo "Maktabati Makefile Commands"
	@echo "=============================="
	@echo "make install      - Install dependencies"
	@echo "make dev          - Start dev server"
	@echo "make build        - Build for production"
	@echo "make preview      - Preview production build (handles existing servers)"
	@echo "make e2e          - Run E2E tests (auto-starts server if needed)"
	@echo "make e2e-ui       - Run E2E tests in UI mode"
	@echo "make e2e-report   - Show E2E test report"
	@echo "make test         - Run all tests"
	@echo "make clean        - Clean build artifacts"
	@echo ""
	@echo "Advanced:"
	@echo "make server-check - Check if preview server is running"
	@echo "make server-kill  - Force kill the server on port 4173"

install:
	npm ci

dev:
	npm run docs:dev

build:
	npm run docs:build

# Interactive preview command
preview:
	@if make server-check > /dev/null 2>&1; then \
		echo "⚠️  Warning: A server is already running on port 4173."; \
		make server-check; \
		read -p "❓ Do you want to stop the existing server and start a new one? (y/n) " confirm; \
		if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
			echo "🛑 Stopping existing server..."; \
			make server-kill; \
			sleep 1; \
			echo "✅ Starting new preview server..."; \
			npm run docs:preview; \
		else \
			echo "ℹ️  Keeping existing server running. Access it at http://localhost:4173/maktabati/"; \
		fi; \
	else \
		echo "✅ No server running. Starting preview server..."; \
		npm run docs:preview; \
	fi

server-check:
	@echo "Checking if preview server is running on http://localhost:4173..."
	@if curl -sf http://localhost:4173/maktabati/ > /dev/null 2>&1; then \
		PID=$$(lsof -ti :4173 2>/dev/null || ss -tulpn | grep :4173 | grep -oP 'pid=\K\d+' | head -1); \
		echo "✓ Server is running (PID: $$PID)"; \
		exit 0; \
	else \
		echo "✗ Server not running on port 4173"; \
		exit 1; \
	fi

server-kill:
	@echo "🛑 Attempting to kill process on port 4173..."
	@PID=$$(lsof -ti :4173 2>/dev/null); \
	if [ -n "$$PID" ]; then \
		kill -9 $$PID 2>/dev/null && echo "✅ Process $$PID killed successfully." || echo "⚠️  Failed to kill process $$PID."; \
	else \
		echo "ℹ️  No process found on port 4173."; \
	fi

# Run tests with intelligent server management
test: e2e

e2e:
	@echo "Running E2E tests with fail-fast..."
	@if make server-check > /dev/null 2>&1; then \
		echo "✓ Using existing server"; \
		npx playwright test --max-failures=1; \
	else \
		echo "⚠ Server not running. Building and starting preview server..."; \
		npm run docs:build && \
		echo "Starting preview server in background..."; \
		npm run docs:preview > /tmp/preview.log 2>&1 & \
		PREVIEW_PID=$$!; \
		echo "Waiting for server to be ready (checking every 1s)..."; \
		for i in {1..15}; do \
			if curl -sf http://localhost:4173/maktabati/ > /dev/null 2>&1; then \
				echo "✓ Server started successfully."; \
				break; \
			fi; \
			sleep 1; \
		done; \
		if curl -sf http://localhost:4173/maktabati/ > /dev/null 2>&1; then \
			npx playwright test --max-failures=1; \
			TEST_RESULT=$$?; \
			kill $$PREVIEW_PID 2>/dev/null || true; \
			exit $$TEST_RESULT; \
		else \
			echo "✗ Failed to start server within timeout."; \
			cat /tmp/preview.log; \
			kill $$PREVIEW_PID 2>/dev/null || true; \
			exit 1; \
		fi; \
	fi

e2e-ui:
	@echo "Running E2E tests in UI mode..."
	@if make server-check > /dev/null 2>&1; then \
		echo "✓ Using existing server"; \
		npx playwright test --ui; \
	else \
		echo "⚠ Server not running. Building and starting preview server..."; \
		npm run docs:build && npm run docs:preview & \
		sleep 3; \
		npx playwright test --ui; \
	fi

e2e-f:
	@echo "Running full E2E test suite..."
	@if make server-check > /dev/null 2>&1; then \
		echo "✓ Using existing server"; \
		npx playwright test; \
	else \
		echo "⚠ Server not running. Building and starting preview server..."; \
		npm run docs:build && \
		echo "Starting preview server in background..."; \
		npm run docs:preview > /tmp/preview.log 2>&1 & \
		PREVIEW_PID=$$!; \
		echo "Waiting for server to be ready..."; \
		for i in {1..15}; do \
			if curl -sf http://localhost:4173/maktabati/ > /dev/null 2>&1; then \
				echo "✓ Server started successfully."; \
				break; \
			fi; \
			sleep 1; \
		done; \
		if curl -sf http://localhost:4173/maktabati/ > /dev/null 2>&1; then \
			npx playwright test; \
			TEST_RESULT=$$?; \
			kill $$PREVIEW_PID 2>/dev/null || true; \
			exit $$TEST_RESULT; \
		else \
			echo "✗ Failed to start server within timeout."; \
			cat /tmp/preview.log; \
			kill $$PREVIEW_PID 2>/dev/null || true; \
			exit 1; \
		fi; \
	fi

e2e-report:
	npx playwright show-report

clean:
	rm -rf node_modules docs/.vitepress/dist

gitpush:
	echo "Building documentation..."
	make build
	echo "Running E2E tests..."
	make e2e
	echo "All Tests Passed! Committing and pushing changes to GitHub..."
	git push origin main