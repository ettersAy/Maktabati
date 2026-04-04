---
title: Makefile Best Practices
description: Guide to writing effective Makefiles for Laravel and Vue projects
---

# Makefile Best Practices

Complete guide to writing maintainable Makefiles for web development projects, specifically for Laravel 13 + Vue 3 stacks.

## Why Use Make?

Makefiles provide:
- **Quick shortcuts:** `make dev` instead of `npm run docs:dev`
- **Automation:** Run checks before tests
- **Documentation:** Self-documenting commands
- **Consistency:** Same commands across team
- **Intelligence:** Conditional logic (check if server running)

## Basics

### Simple Makefile

```makefile
# Comments start with #

target: dependencies
	command

.PHONY: help
```

**Example:**

```makefile
.PHONY: dev

dev:
	npm run docs:dev
```

Run with: `make dev`

### Key Syntax

- `.PHONY:` - Mark targets as "not files"
- `:` - Target separator
- `tab` - Required indentation (not spaces!)
- `@` - Hide command output
- `$()` - Variable reference

⚠️ **Important:** Makefile indentation MUST be tabs, not spaces!

---

## Structure

### Well-Organized Makefile

```makefile
# =============================================================================
# PROJECT CONFIG
# =============================================================================

PROJECT_NAME := myproject
NODE_VERSION := 22

# =============================================================================
# TARGETS AND HELP
# =============================================================================

.PHONY: help
help:
	@echo "$(PROJECT_NAME) Makefile"
	@echo "========================"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "%-20s %s\n", $$1, $$2}'

# =============================================================================
# DEVELOPMENT
# =============================================================================

.PHONY: install
install: ## Install dependencies
	npm ci

.PHONY: dev
dev: ## Start development server
	npm run dev

# =============================================================================
# TESTING
# =============================================================================

.PHONY: test
test: ## Run tests
	npm test

# =============================================================================
# BUILD & DEPLOY
# =============================================================================

.PHONY: build
build: ## Build for production
	npm run build

# =============================================================================
# CLEANUP
# =============================================================================

.PHONY: clean
clean: ## Clean build artifacts
	rm -rf dist/ node_modules/
```

---

## For Laravel + Vue Projects

### Typical Stack

```
Backend:  Laravel 13 (Sail + Docker)
Frontend: Vue 3 (Vite)
Testing:  PHPUnit + Playwright
```

### Recommended Targets

```makefile
# Installation
make install-deps      # npm install + composer install
make db-seed          # Fill database with test data

# Development
make dev              # Start all services
make artisan          # Run Laravel artisan commands
make tinker           # Open Laravel Tinker

# Testing
make test             # Run all tests
make test-unit        # Unit tests only
make test-e2e         # End-to-end tests
make test-watch       # Watch for changes

# Building
make build            # Production build
make optimize        # Cache config/routes

# Server checks
make health-check    # Verify all services running
make logs            # Tail application logs

# Cleanup
make clean           # Remove build artifacts
make db-reset        # Reset database
```

---

## Smart Makefiles: Add Intelligence

### Check If Command Exists

```makefile
.PHONY: install
install:
	@command -v npm >/dev/null 2>&1 || { \
		echo "npm not found. Install Node.js first"; \
		exit 1; \
	}
	npm ci
```

### Check If Process Is Running

```makefile
.PHONY: server-check
server-check:
	@if curl -sf http://localhost:3000 > /dev/null 2>&1; then \
		echo "✓ Server running on port 3000"; \
	else \
		echo "✗ Server not running"; \
		exit 1; \
	fi

.PHONY: test
test: server-check  ## Run tests (error if server down)
	npm run test
```

### Conditional Logic

```makefile
.PHONY: test
test:
	@echo "Running tests..."
	@if [ -f ".env.test" ]; then \
		npm run test:ci; \
	else \
		echo "⚠ .env.test not found, using defaults"; \
		npm run test; \
	fi
```

### Auto-Start Services

```makefile
.PHONY: dev
dev:
	@echo "Starting development environment..."
	@if ! command -v docker &> /dev/null; then \
		echo "Docker not found"; \
		exit 1; \
	fi
	docker-compose up -d
	@echo "✓ Services started"
	@make health-check

.PHONY: health-check
health-check:
	@echo "Checking services..."
	@sleep 2
	@curl -sf http://localhost:3000 || echo "App not ready"
```

---

## Advanced Patterns

### Variables for DRY Code

```makefile
# Define once, use many times
PHP_CONTAINER := laravel-app
ARTISAN := docker exec $(PHP_CONTAINER) php artisan
SAIL := ./vendor/bin/sail

.PHONY: migrate
migrate:  ## Run migrations
	$(ARTISAN) migrate

.PHONY: seed
seed:  ## Seed database
	$(ARTISAN) db:seed

.PHONY: tinker
tinker:  ## Open Tinker console
	$(SAIL) tinker
```

### Parallel Execution

```makefile
.PHONY: test-all
test-all:  ## Run all tests in parallel
	@echo "Running tests in parallel..."
	@npm run test:unit & \
	npm run test:e2e & \
	npm run lint & \
	wait
	@echo "✓ All tests passed"

.PHONY: build-all
build-all:  ## Build backend and frontend
	@echo "Building..."
	@npm run build & \
	composer build & \
	wait
	@echo "✓ Build complete"
```

### Error Handling

```makefile
.PHONY: deploy
deploy:  ## Deploy to production (with safety checks)
	@if [ ! -f ".env.production" ]; then \
		echo "Error: .env.production not found"; \
		exit 1; \
	fi
	@if git status --porcelain | grep -q .; then \
		echo "Error: Uncommitted changes"; \
		exit 1; \
	fi
	@echo "Deploying..."
	npm run build
	@echo "✓ Deployment ready"
```

### Help Text Generation

```makefile
.PHONY: help
help:
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

# Usage:
# make install    ## Install dependencies
# make dev        ## Start dev server
# make test       ## Run tests
```

Output:
```
Available commands:
  install              Install dependencies
  dev                  Start dev server
  test                 Run tests
```

---

## For Docker-Based Projects (Sail)

### Laravel Sail Integration

```makefile
SAIL := ./vendor/bin/sail
ARTISAN := $(SAIL) artisan
COMPOSER := $(SAIL) composer
NPM := $(SAIL) npm

.PHONY: sail-up
sail-up:  ## Start Sail containers
	$(SAIL) up -d

.PHONY: sail-down
sail-down:  ## Stop Sail containers
	$(SAIL) down

.PHONY: sail-fresh
sail-fresh:  ## Reset database with seeds
	$(ARTISAN) migrate:fresh --seed

.PHONY: logs
logs:  ## Tail application logs
	$(SAIL) logs -f

.PHONY: shell
shell:  ## Open shell in app container
	$(SAIL) shell

.PHONY: npm-install
npm-install:  ## Install npm deps in container
	$(NPM) install

.PHONY: composer-install
composer-install:  ## Install composer deps in container
	$(COMPOSER) install
```

---

## Common Issues

### Issue: "missing separator"

**Cause:** Used spaces instead of tabs for indentation.

**Fix:**
```makefile
target:
[TAB]command  ← Must be TAB, not spaces
```

### Issue: Variable not expanding

**Cause:** Used single quotes or forgot `${}`.

**Fix:**
```makefile
# Wrong
VAR = value
command: $(VAR)  ← $(VAR) works
	@echo '$VAR'  ← Single quotes prevent expansion

# Correct
@echo "$(VAR)"  ← Always use $()
```

### Issue: Commands not executing

**Cause:** Target has dependencies that failed.

**Fix:**
```makefile
# Ensure dependencies pass
make dep1 && make target
```

---

## Best Practices

### ✅ Do

- Use `.PHONY:` for all non-file targets
- Add help text with `##` comments
- Check for prerequisites (Docker, Node)
- Use variables to avoid repetition
- Keep commands simple and focused
- Document complex logic
- Group related targets with comments

### ❌ Don't

- Mix tabs and spaces (tabs only!)
- Use spaces in target names
- Create targets that delete important files
- Ignore error codes (`|| true` sparingly)
- Write complex shell scripts (create `.sh` files instead)
- Use hardcoded paths (use variables)

---

## Examples

### Static Site (VitePress/Hugo)

```makefile
.PHONY: install dev build preview clean

install:
	npm ci

dev:
	npm run dev

build:
	npm run build

preview:
	npm run preview

clean:
	rm -rf dist/
```

### Laravel App

```makefile
.PHONY: install devel test migrate seed fresh

install:
	composer install
	npm install

dev:
	php artisan serve

test:
	php artisan test

migrate:
	php artisan migrate

seed:
	php artisan db:seed

fresh:
	php artisan migrate:fresh --seed
```

### Full Stack (Laravel + Vue + Docker)

```makefile
DOCKER := docker-compose
ARTISAN := ./vendor/bin/sail artisan
NPM := ./vendor/bin/sail npm

.PHONY: up down fresh migrate test build

up:
	$(DOCKER) up -d

down:
	$(DOCKER) down

fresh:
	$(ARTISAN) migrate:fresh --seed

migrate:
	$(ARTISAN) migrate

test:
	$(ARTISAN) test

build:
	$(NPM) run build
	$(ARTISAN) config:cache
```

---

## Resources

- [GNU Make Manual](https://www.gnu.org/software/make/manual/)
- [Make by Example](https://makefiletutorial.com/)
- [Makefile Cookbook](https://www.gnu.org/software/make/manual/html_node/Recipes.html)

---

*Last updated: April 2026 | For Laravel 13 + Vue 3 projects*
