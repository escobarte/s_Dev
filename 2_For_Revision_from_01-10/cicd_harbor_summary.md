# CI/CD with Harbor Registry - Implementation Summary

## Project Overview

Successfully implemented a professional CI/CD pipeline for Laravel application using GitLab CI/CD and Harbor Registry in an isolated corporate network.

**Infrastructure:**
- **Server 10.100.93.6** (Production) - Harbor Registry + Production deployment
- **Server 10.100.93.7** (Test) - Test environment deployment
- **GitLab Runners** on both servers with different tags

---

## Phase 1: Initial Docker Production Setup

### Production Docker Container Created

**Goal:** Transform Laravel from 4 separate containers to 1 production-ready container.

**Key Components:**
- `Dockerfile.prod` - Multi-stage build (Node builder + PHP base + Final app)
- `docker/nginx.conf` - Nginx configuration inside container
- `docker/supervisord.conf` - Process manager (runs nginx + php-fpm simultaneously)
- `docker/start.sh` - Startup script (database initialization, migrations, optimization)

**Technologies Used:**
- Supervisor - manages multiple processes in single container
- SQLite - embedded database for simplicity
- Multi-stage build - optimizes final image size
- Docker volumes - persistent data storage

**Critical Decisions:**
- SQLite chosen over MySQL for simplicity in production
- Supervisor allows nginx + php-fpm in one container
- Volume for database prevents data loss on container restart

---

## Phase 2: Git Flow Strategy

### Branch-Based Deployment Strategy

**Workflow Implemented:**

```
feature/* branches  → Build only (test compilation)
develop-* branches  → Build + Deploy to Test (10.100.93.7:8080)
master branch       → Build + Deploy Test + Deploy Prod (manual, 10.100.93.6:8080)
```

**Pipeline Stages:**
1. **build** - Compile Docker image (runs on all branches)
2. **deploy** - Auto-deploy to test server (develop-* branches only)
3. **prod** - Manual deploy to production (master branch only)

**GitLab CI/CD Configuration:**
- `only: variables:` with regex `/^develop.*/` for flexible branch matching
- `when: manual` for production deployment safety
- Runner tags differentiate servers: `ci`, `test-deploy`, `prod-only`

---

## Phase 3: Docker Permissions Issue

### Problem Encountered

GitLab runner couldn't access Docker daemon on servers.

**Error:** `permission denied while trying to connect to the Docker daemon socket`

**Solution:**
```bash
# On both servers (10.100.93.6 and 10.100.93.7)
sudo usermod -aG docker gitlab-runner
sudo systemctl restart gitlab-runner
sudo -u gitlab-runner docker ps  # Test access
```

**Why This Matters:**
- GitLab runner needs Docker group membership to execute docker commands
- Required on all servers running runners
- One-time configuration per server

---

## Phase 4: Harbor Registry Implementation

### Why Harbor Instead of Alternatives

**Requirements:**
- No external internet access (isolated corporate network)
- No access to public registries (DockerHub, GitLab Registry)
- Professional enterprise solution needed

**Options Considered:**
1. ❌ GitLab Container Registry - requires external access
2. ❌ DockerHub - not allowed in corporate network
3. ❌ Simple Docker Registry v2 - lacks web UI and features
4. ❌ NFS + docker save/load - too primitive
5. ✅ **Harbor** - enterprise-ready, self-hosted, full features

**Harbor Advantages:**
- Web UI for image management
- User authentication and RBAC
- Vulnerability scanning
- Replication policies
- Audit logging
- No external dependencies

### Harbor Installation (Server 10.100.93.6)

**Prerequisites:**
```bash
# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Download Harbor offline installer
cd /opt
wget https://github.com/goharbor/harbor/releases/download/v2.9.0/harbor-offline-installer-v2.9.0.tgz
tar xvf harbor-offline-installer-v2.9.0.tgz
cd harbor
```

**Configuration (harbor.yml):**
```yaml
hostname: 10.100.93.6
http:
  port: 81  # Custom port (8080 reserved for app)
harbor_admin_password: Harbor12345
database:
  password: root123
data_volume: /opt/harbor-data
_version: 2.9.0
```

**Installation:**
```bash
./prepare
./install.sh
docker-compose ps  # Verify all services running
```

**Harbor Access:**
- URL: http://10.100.93.6:81
- Default user: admin
- Password: Harbor12345

### Docker Configuration for Harbor

**Critical Step - Configure Insecure Registry:**

Since Harbor runs on HTTP (no HTTPS), Docker needs to allow insecure connections.

**On ALL servers (10.100.93.6 and 10.100.93.7):**
```bash
# Create Docker daemon configuration
sudo mkdir -p /etc/docker
echo '{
  "insecure-registries": ["10.100.93.6:81"]
}' | sudo tee /etc/docker/daemon.json

# Restart Docker
sudo systemctl restart docker
sudo systemctl restart gitlab-runner

# Restart Harbor (on 10.100.93.6 only)
cd /opt/harbor
docker-compose start
```

**Why This Is Critical:**
- Without this config: `Error: HTTP response to HTTPS client`
- Must be done on every server that needs to push/pull images
- Allows HTTP communication with Harbor registry

### Harbor Project Setup

**In Harbor Web UI:**
1. Login: http://10.100.93.6:81
2. Create project: `laravel-blog`
3. Create user: `harbor-admin` (or use existing)
4. Set project as **Private** (not public - security best practice)
5. Add user to project with Developer/Master role

**Project Access:**
- Private projects require authentication
- More secure than public projects
- Credentials managed via GitLab CI/CD variables

---

## Phase 5: GitLab CI/CD Integration with Harbor

### Secure Credential Management

**Never hardcode credentials in .gitlab-ci.yml!**

**GitLab CI/CD Variables (Secure Method):**

Navigate to: **GitLab Project → Settings → CI/CD → Variables**

Add these variables:
- `HARBOR_USERNAME`: `harbor-admin`
- `HARBOR_PASSWORD`: `Harbor123`
- ⚠️ **Uncheck "Protected"** - allows use on non-protected branches
- ✅ Check "Masked" - hides values in logs

**Why "Protected" Must Be Unchecked:**
- Protected variables only work on protected branches (master/main)
- Develop branches need access too
- First pipeline failed because variables were protected

### Updated .gitlab-ci.yml Configuration

**Variables Section:**
```yaml
variables:
  HARBOR_REGISTRY: 10.100.93.6:81
  PROJECT_NAME: laravel-blog
  DOCKER_IMAGE: $HARBOR_REGISTRY/$PROJECT_NAME/laravel-app:$CI_COMMIT_SHA
  DOCKER_LATEST: $HARBOR_REGISTRY/$PROJECT_NAME/laravel-app:latest
  # HARBOR_USERNAME and HARBOR_PASSWORD come from GitLab variables
```

**Build Stage - Harbor Authentication:**
```yaml
build:
  stage: build
  tags:
    - ci
  before_script:
    - echo "Harbor Registry:" $HARBOR_REGISTRY
    - echo "Project:" $PROJECT_NAME
    - echo "Commit:" $CI_COMMIT_SHA
    - echo "Logging into Harbor registry..."
    - echo $HARBOR_PASSWORD | docker login -u $HARBOR_USERNAME --password-stdin $HARBOR_REGISTRY
  script:
    - docker build -f Dockerfile.prod -t $DOCKER_IMAGE .
    - docker tag $DOCKER_IMAGE $DOCKER_LATEST
    - docker push $DOCKER_IMAGE
    - docker push $DOCKER_LATEST
    - echo "Image pushed to Harbor: $DOCKER_IMAGE"
  except:
    - tags
```

**Deploy Stage - Harbor Authentication:**
```yaml
deploy:
  stage: deploy
  tags:
    - test-deploy
  before_script:
    - echo $HARBOR_PASSWORD | docker login -u $HARBOR_USERNAME --password-stdin $HARBOR_REGISTRY
  script:
    - docker pull $DOCKER_IMAGE
    - docker stop laravel-blog-test || true
    - docker rm laravel-blog-test || true
    - docker volume create laravel-test-db || true
    - docker run -d --name laravel-blog-test --restart unless-stopped -p 8080:80 -v laravel-test-db:/var/www/html/database $DOCKER_IMAGE
    - sleep 10
    - echo "Test deployment complete: http://10.100.93.7:8080"
  needs:
    - build
  only:
    variables:
      - $CI_COMMIT_REF_NAME =~ /^develop.*/
```

**Production Stage - Harbor Authentication:**
```yaml
prod:
  stage: prod
  tags:
    - prod-only
  before_script:
    - echo $HARBOR_PASSWORD | docker login -u $HARBOR_USERNAME --password-stdin $HARBOR_REGISTRY
  script:
    - docker pull $DOCKER_IMAGE
    - docker stop laravel-blog-prod || true
    - docker rm laravel-blog-prod || true
    - docker volume create laravel-prod-db || true
    - docker run -d --name laravel-blog-prod --restart unless-stopped -p 8080:80 -v laravel-prod-db:/var/www/html/database $DOCKER_IMAGE
    - sleep 10
    - echo "Production deployment complete: http://10.100.93.6:8080"
  needs:
    - build
  only:
    - master
  when: manual
```

**Key Changes from GitLab Registry:**
- Changed all `$CI_REGISTRY*` variables to `$HARBOR_REGISTRY`
- Added Harbor authentication in `before_script` for all stages
- Image naming follows Harbor format: `registry/project/image:tag`
- Authentication uses GitLab CI/CD variables

---

## Critical Issues & Solutions

### Issue 1: "username is empty"

**Problem:** Harbor credentials not accessible in pipeline.

**Root Cause:** GitLab CI/CD variables marked as "Protected".

**Solution:**
1. Go to Settings → CI/CD → Variables
2. Uncheck "Protected" for HARBOR_USERNAME and HARBOR_PASSWORD
3. Protected variables only work on protected branches (master)
4. Develop branches need unprotected variables

### Issue 2: Typo in Variable Name

**Problem:** `$HARBOR_PASSWROD` instead of `$HARBOR_PASSWORD`

**Impact:** Empty password passed to docker login.

**Lesson:** Always double-check variable names - typos cause silent failures.

### Issue 3: Docker Permission Denied

**Problem:** GitLab runner can't access Docker daemon.

**Solution:** Add gitlab-runner user to docker group on all servers.

### Issue 4: HTTP vs HTTPS

**Problem:** Docker tries HTTPS but Harbor runs on HTTP.

**Solution:** Configure insecure-registries in /etc/docker/daemon.json.

### Issue 5: Network Connectivity

**Problem:** Server 10.100.93.7 couldn't reach Harbor.

**Testing Steps:**
```bash
ping 10.100.93.6
telnet 10.100.93.6 81
curl -v http://10.100.93.6:81/v2/
```

**Verification:** 401 Unauthorized = Harbor is reachable and working correctly.

---

## Storage and Maintenance

### Harbor Data Storage

**Location:** `/opt/harbor-data/` (configured in harbor.yml)

**Directory Structure:**
```
/opt/harbor-data/
├── registry/          # Docker images and layers
├── database/          # PostgreSQL (users, projects, policies)
├── redis/            # Cache data
├── job_logs/         # Build and scan logs
└── ca_download/      # Certificates
```

**Check Storage Usage:**
```bash
du -sh /opt/harbor-data/
du -sh /opt/harbor-data/registry/  # Image storage
```

**Important Notes:**
- Registry folder grows with each image push
- Harbor deduplicates image layers automatically
- Regular cleanup policies recommended for production

---

## Final Architecture

### Complete CI/CD Flow

```
Developer pushes code to GitLab
         ↓
GitLab triggers pipeline based on branch
         ↓
┌─────────────────────────────────────────┐
│ BUILD STAGE (any branch)                │
│ - Runs on server 10.100.93.6           │
│ - Builds Docker image                   │
│ - Pushes to Harbor (10.100.93.6:81)    │
└─────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│ DEPLOY STAGE (develop-* branches only)  │
│ - Runs on server 10.100.93.7           │
│ - Pulls image from Harbor               │
│ - Deploys to test environment           │
│ - URL: http://10.100.93.7:8080         │
└─────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│ PROD STAGE (master branch only)         │
│ - Manual trigger required               │
│ - Runs on server 10.100.93.6           │
│ - Pulls image from Harbor               │
│ - Deploys to production                 │
│ - URL: http://10.100.93.6:8080         │
└─────────────────────────────────────────┘
```

### Server Roles

**Server 10.100.93.6 (Production):**
- Harbor Registry (port 81)
- Production Laravel app (port 8080)
- GitLab runner with tags: `ci`, `prod-only`

**Server 10.100.93.7 (Test):**
- Test Laravel app (port 8080)
- GitLab runner with tags: `test-deploy`

---

## Key Takeaways

### Technical Achievements

✅ **Zero external dependencies** - completely isolated network
✅ **Enterprise-grade registry** - Harbor with authentication and UI
✅ **Multi-server deployment** - separate test and production environments
✅ **Git Flow integration** - branch-based deployment strategy
✅ **Security best practices** - private projects, credential masking, manual prod deployment
✅ **Persistent data** - Docker volumes prevent data loss
✅ **Production-ready containers** - single container with supervisor

### Best Practices Implemented

1. **Never hardcode credentials** - use GitLab CI/CD variables
2. **Private registry projects** - always authenticate
3. **Manual production deployments** - prevent accidental releases
4. **Branch-based workflows** - different rules for different branches
5. **Insecure registry config** - required for HTTP registries
6. **Docker user permissions** - gitlab-runner needs docker group
7. **Volume persistence** - separate data from containers
8. **Multi-stage builds** - optimize image size

### Common Pitfalls Avoided

❌ Hardcoding credentials in .gitlab-ci.yml
❌ Using public projects without authentication
❌ Protected variables blocking non-protected branches
❌ Missing insecure-registries configuration
❌ Forgetting to add gitlab-runner to docker group
❌ Not configuring Docker on all servers
❌ Typos in variable names causing silent failures

---

## Quick Reference Commands

### Harbor Management
```bash
# Start Harbor
cd /opt/harbor && docker-compose start

# Stop Harbor
cd /opt/harbor && docker-compose stop

# View Harbor logs
cd /opt/harbor && docker-compose logs -f

# Check Harbor status
docker-compose ps
```

### Docker Registry Operations
```bash
# Login to Harbor
docker login 10.100.93.6:81

# Push image to Harbor
docker tag myimage:latest 10.100.93.6:81/laravel-blog/myimage:latest
docker push 10.100.93.6:81/laravel-blog/myimage:latest

# Pull image from Harbor
docker pull 10.100.93.6:81/laravel-blog/myimage:latest

# List local images
docker images | grep 10.100.93.6
```

### GitLab Runner Management
```bash
# Check runner status
sudo gitlab-runner status

# Restart runner
sudo systemctl restart gitlab-runner

# View runner logs
sudo journalctl -u gitlab-runner -f
```

### Troubleshooting
```bash
# Test Harbor connectivity
curl -v http://10.100.93.6:81/v2/

# Test Docker login
docker login 10.100.93.6:81

# Check insecure registry config
cat /etc/docker/daemon.json

# Verify gitlab-runner Docker access
sudo -u gitlab-runner docker ps

# Check Harbor storage
du -sh /opt/harbor-data/
```

---

## Conclusion

Successfully implemented a complete enterprise CI/CD solution using Harbor Registry in an isolated corporate network. The system handles multi-server deployments with branch-based workflows, secure credential management, and production-grade container orchestration.

**Mission accomplished:** Professional CI/CD without external dependencies.