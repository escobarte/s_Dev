# DevOps CI/CD Learning Guide - Critical Concepts

## Table of Contents
1. [Core CI/CD Concepts](#core-cicd-concepts)
2. [Laravel Project Structure](#laravel-project-structure)
3. [Infrastructure Architecture](#infrastructure-architecture)
4. [Docker vs Native Deployment](#docker-vs-native-deployment)
5. [Deployment Pipeline Stages](#deployment-pipeline-stages)
6. [Key Files Reference](#key-files-reference)

---

## Core CI/CD Concepts

### What is CI/CD?
**Continuous Integration / Continuous Deployment** - automated process of building, testing, and deploying code.

### The Organic Approach
1. **Understand the project first** (local testing)
2. **Set up infrastructure** (servers, services)
3. **Create build process** (Docker images)
4. **Automate deployment** (GitLab CI)
5. **Monitor and iterate**

### Critical Rule
**Never rush to write CI/CD pipelines before understanding what the application needs!**

---

## Laravel Project Structure

### Essential Files for DevOps

#### `composer.json`
**Purpose**: PHP dependency management (like package.json for Node.js)

**Key sections**:
- `"require"`: Production dependencies (needed on server)
- `"require-dev"`: Development tools (tests, linters)

```json
{
  "require": {
    "php": "^8.3",              // PHP version requirement
    "laravel/framework": "^11.28" // Laravel version
  },
  "require-dev": {
    "phpunit/phpunit": "11.4.1",  // Testing framework
    "laravel/pint": "1.18.1"      // Code style checker
  }
}
```

#### `.env.example`
**Purpose**: Template for environment variables

**Critical settings**:
```env
APP_ENV=production        # Environment type
APP_DEBUG=false          # MUST be false in production!
DB_HOST=127.0.0.1        # Database server
DB_DATABASE=laravel_blog # Database name
REDIS_HOST=127.0.0.1     # Redis server
```

#### `package.json`
**Purpose**: Frontend dependencies (JavaScript, CSS)

---

## Infrastructure Architecture

### Our Architecture (Hybrid Approach)

```
┌─────────────────────────────────────────────┐
│  10.100.93.4 - Nginx (Reverse Proxy)       │
│  Native installation                        │
└─────────────┬───────────────────────────────┘
              │
      ┌───────┴───────┐
      │               │
┌─────▼─────┐   ┌────▼──────┐
│ Test Env  │   │ Prod Env  │
│ .93.5     │   │ .93.6     │
│ Docker    │   │ Docker    │
└─────┬─────┘   └────┬──────┘
      │              │
      └──────┬───────┘
             │
      ┌──────▼──────┐
      │  Database   │
      │  .93.7      │
      │  Native SQL │
      └─────────────┘
```

### Server Roles

| Server | Role | Technology |
|--------|------|------------|
| 10.100.93.4 | Load Balancer / Proxy | Native Nginx |
| 10.100.93.5 | CI/CD + Testing | GitLab Runner + Docker |
| 10.100.93.6 | Production App | Docker Containers |
| 10.100.93.7 | Database | Native MySQL |

---

## Docker vs Native Deployment

### Why Docker?
- **Portability**: Same environment everywhere
- **Isolation**: No conflicts between applications
- **Scalability**: Easy to run multiple instances
- **Rollback**: Quick return to previous version

### What Goes in Docker Container?
✅ Laravel application
✅ PHP runtime
✅ Application dependencies
✅ Redis (optional)

### What Stays Native?
✅ Nginx (reverse proxy)
✅ MySQL database (can be Docker, but often native for stability)
✅ GitLab Runner

---

## Deployment Pipeline Stages

### Stage 1: Test
**Purpose**: Verify code quality before deployment

```yaml
test:
  script:
    - composer install          # Install ALL dependencies (including dev)
    - php artisan test          # Run automated tests
    - ./vendor/bin/pint --test  # Check code style
```

### Stage 2: Build
**Purpose**: Create deployable artifact (Docker image)

```yaml
build:
  script:
    - docker build -t myapp:$CI_COMMIT_SHA .
    - docker push registry.gitlab.com/myapp:$CI_COMMIT_SHA
```

### Stage 3: Deploy
**Purpose**: Deploy to target server

```yaml
deploy:
  script:
    - docker pull myapp:$CI_COMMIT_SHA
    - docker-compose up -d
```

---

## Key Files Reference

### Files You Must Understand

#### For Application Analysis
- `README.md` - Project overview
- `composer.json` - PHP dependencies
- `package.json` - Frontend dependencies
- `.env.example` - Configuration template

#### For CI/CD Setup
- `Dockerfile` - Container build instructions
- `docker-compose.yml` - Multi-container orchestration
- `.gitlab-ci.yml` - CI/CD pipeline definition

#### For Server Configuration
- `/etc/nginx/sites-available/` - Nginx configs
- `/etc/supervisor/conf.d/` - Background processes

---

## Critical Concepts Explained

### `require` vs `require-dev`

**Analogy**: Car vs Mechanic's Tools

```
require     = Engine, wheels, steering wheel (car runs with these)
require-dev = Wrenches, diagnostic tools (mechanic needs for maintenance)
```

**In practice**:
- Development/CI: `composer install` (installs both)
- Production: `composer install --no-dev` (only require)

### Artifact
**Definition**: Final packaged product ready for deployment

In our case: **Docker Image** containing:
- Laravel application code
- PHP runtime
- All production dependencies
- Configuration files

### Environment Variables
**Definition**: Settings that change between environments

Example:
```
Development: APP_DEBUG=true, DB_HOST=localhost
Production:  APP_DEBUG=false, DB_HOST=10.100.93.7
```

---

## Common Commands Reference

### Docker Commands
```bash
# Build image
docker build -t myapp:latest .

# Run container
docker run -d -p 8000:8000 myapp:latest

# View running containers
docker ps

# View logs
docker logs container_name

# Stop container
docker stop container_name
```

### Laravel Commands
```bash
# Install dependencies
composer install --no-dev --optimize-autoloader

# Run migrations
php artisan migrate --force

# Cache configuration
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Run tests
php artisan test
```

### GitLab Runner Commands
```bash
# Check runner status
gitlab-runner status

# List registered runners
gitlab-runner list

# Verify connection
gitlab-runner verify
```

---

## Step-by-Step Learning Process

### Phase 1: Understanding
1. ✅ Clone project from GitHub
2. ✅ Read README.md
3. ✅ Analyze composer.json
4. ✅ Check .env.example
5. ✅ Run locally to understand behavior

### Phase 2: Infrastructure Setup
6. ⏳ Verify Docker on servers
7. ⏳ Configure GitLab Runner
8. ⏳ Set up Docker Registry
9. ⏳ Prepare database server

### Phase 3: Containerization
10. ⏳ Create Dockerfile
11. ⏳ Create docker-compose.yml
12. ⏳ Test locally with Docker
13. ⏳ Push to GitLab

### Phase 4: CI/CD Pipeline
14. ⏳ Write .gitlab-ci.yml
15. ⏳ Test pipeline on staging
16. ⏳ Deploy to production
17. ⏳ Set up monitoring

---

## Important Reminders

### Security
- ⚠️ **NEVER** set `APP_DEBUG=true` in production
- ⚠️ **ALWAYS** generate unique `APP_KEY` for each environment
- ⚠️ **NEVER** commit `.env` file to Git
- ⚠️ Use strong database passwords

### Best Practices
- ✅ Test locally before pushing to CI/CD
- ✅ Use semantic versioning for Docker images
- ✅ Keep production and staging environments identical
- ✅ Monitor logs and metrics
- ✅ Have rollback plan ready

### Common Mistakes to Avoid
- ❌ Skipping the understanding phase
- ❌ Installing dev dependencies on production
- ❌ Not testing Docker containers locally first
- ❌ Hardcoding environment-specific values
- ❌ Not backing up database before migrations

---

## Next Steps

**Current Progress**: Understanding phase complete

**Next Milestones**:
1. Verify Docker installation on servers
2. Create Dockerfile for Laravel project
3. Test Docker build locally
4. Write GitLab CI/CD pipeline
5. Deploy to staging environment
6. Deploy to production

---

## Glossary

| Term | Definition |
|------|------------|
| **Artifact** | Packaged product ready for deployment (Docker image) |
| **CI/CD** | Automated build, test, and deployment pipeline |
| **Container** | Isolated environment running your application |
| **Image** | Blueprint for creating containers |
| **Registry** | Storage for Docker images |
| **Runner** | Service that executes CI/CD jobs |
| **Pipeline** | Series of automated steps (test → build → deploy) |
| **Stage** | Phase in pipeline (test, build, deploy) |
| **Job** | Single task within a stage |

---

**Document Version**: 1.0
**Last Updated**: 2025-10-01
**Project**: Laravel Blog CI/CD Implementation