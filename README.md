# Stackvo Tools - Runtime Installation Container

[![Docker Hub](https://img.shields.io/docker/v/stackvo/tools?label=Docker%20Hub)](https://hub.docker.com/r/stackvo/tools)
[![Docker Image Size](https://img.shields.io/docker/image-size/stackvo/tools/latest)](https://hub.docker.com/r/stackvo/tools)
[![Docker Pulls](https://img.shields.io/docker/pulls/stackvo/tools)](https://hub.docker.com/r/stackvo/tools)
[![Build Status](https://github.com/stackvo/stackvo-tools/workflows/Build%20and%20Push%20to%20Docker%20Hub/badge.svg)](https://github.com/stackvo/stackvo-tools/actions)

PHP-based database and cache management tools container with **runtime installation**. Choose which tools to install via environment variables.

## 🎯 Features

- 🚀 **Runtime Installation** - Tools are installed when container starts
- 📦 **Minimal Base Image** - ~450MB (no tools pre-installed)
- 🔧 **Dynamic Configuration** - Enable/disable tools via environment variables
- 💾 **Persistent Storage** - Use volumes to avoid re-downloading tools
- 🎨 **7 Tools Supported** - Adminer, PhpMyAdmin, PhpPgAdmin, PhpMongo, PhpMemcachedAdmin, OpCache, Kafbat

## 📦 Supported Tools

| Tool                  | Version | Description                                   | Size   |
| --------------------- | ------- | --------------------------------------------- | ------ |
| **Adminer**           | 4.8.1   | Database management (MySQL, PostgreSQL, etc.) | ~500KB |
| **PhpMyAdmin**        | 5.2.1   | MySQL/MariaDB management                      | ~15MB  |
| **PhpPgAdmin**        | 7.13.0  | PostgreSQL management                         | ~5MB   |
| **MongoDB-PHP-GUI**   | 1.3.3   | MongoDB management                            | ~10MB  |
| **PhpMemcachedAdmin** | 1.3.0   | Memcached management                          | ~2MB   |
| **OpCacheGUI**        | 3.6.0   | PHP OpCache monitoring                        | ~50KB  |
| **Kafbat Kafka UI**   | 1.4.2   | Kafka management (Java-based)                 | ~50MB  |

## 🚀 Quick Start

### Using Docker Compose (Recommended)

```yaml
version: "3.8"

services:
  stackvo-tools:
    image: stackvo/tools:latest
    container_name: stackvo-tools
    restart: unless-stopped

    ports:
      - "8080:80"

    environment:
      # Enable tools you want to use
      TOOLS_ADMINER_ENABLE: "true"
      TOOLS_PHPMYADMIN_ENABLE: "true"
      TOOLS_PHPPGADMIN_ENABLE: "false"
      TOOLS_PHPMONGO_ENABLE: "false"
      TOOLS_PHPMEMCACHEDADMIN_ENABLE: "false"
      TOOLS_OPCACHE_ENABLE: "false"
      TOOLS_KAFBAT_ENABLE: "false"

      # Optional: Specify versions
      TOOLS_ADMINER_VERSION: "4.8.1"
      TOOLS_PHPMYADMIN_VERSION: "5.2.1"

    volumes:
      # Persist installed tools (avoid re-downloading)
      - tools-data:/var/www/html

    networks:
      - app-network

volumes:
  tools-data:

networks:
  app-network:
    driver: bridge
```

```bash
docker-compose up -d
```

### Using Docker CLI

```bash
docker run -d \
  --name stackvo-tools \
  -p 8080:80 \
  -e TOOLS_ADMINER_ENABLE=true \
  -e TOOLS_PHPMYADMIN_ENABLE=true \
  -v tools-data:/var/www/html \
  stackvo/tools:latest
```

## 🔧 Environment Variables

### Tool Enable Flags

| Variable                         | Default | Description              |
| -------------------------------- | ------- | ------------------------ |
| `TOOLS_ADMINER_ENABLE`           | `false` | Enable Adminer           |
| `TOOLS_PHPMYADMIN_ENABLE`        | `false` | Enable PhpMyAdmin        |
| `TOOLS_PHPPGADMIN_ENABLE`        | `false` | Enable PhpPgAdmin        |
| `TOOLS_PHPMONGO_ENABLE`          | `false` | Enable MongoDB-PHP-GUI   |
| `TOOLS_PHPMEMCACHEDADMIN_ENABLE` | `false` | Enable PhpMemcachedAdmin |
| `TOOLS_OPCACHE_ENABLE`           | `false` | Enable OpCacheGUI        |
| `TOOLS_KAFBAT_ENABLE`            | `false` | Enable Kafbat Kafka UI   |

### Tool Versions

| Variable                          | Default  | Description               |
| --------------------------------- | -------- | ------------------------- |
| `TOOLS_ADMINER_VERSION`           | `4.8.1`  | Adminer version           |
| `TOOLS_PHPMYADMIN_VERSION`        | `5.2.1`  | PhpMyAdmin version        |
| `TOOLS_PHPPGADMIN_VERSION`        | `7.13.0` | PhpPgAdmin version        |
| `TOOLS_PHPMONGO_VERSION`          | `1.3.3`  | MongoDB-PHP-GUI version   |
| `TOOLS_PHPMEMCACHEDADMIN_VERSION` | `1.3.0`  | PhpMemcachedAdmin version |
| `TOOLS_OPCACHE_VERSION`           | `3.6.0`  | OpCacheGUI version        |
| `TOOLS_KAFBAT_VERSION`            | `1.4.2`  | Kafbat Kafka UI version   |

## 🌐 Accessing Tools

Tools are accessible via subdomain-based routing:

| Tool              | URL                                       | Example               |
| ----------------- | ----------------------------------------- | --------------------- |
| Adminer           | `http://adminer.localhost:8080`           | Database management   |
| PhpMyAdmin        | `http://phpmyadmin.localhost:8080`        | MySQL management      |
| PhpPgAdmin        | `http://phppgadmin.localhost:8080`        | PostgreSQL management |
| PhpMongo          | `http://phpmongo.localhost:8080`          | MongoDB management    |
| PhpMemcachedAdmin | `http://phpmemcachedadmin.localhost:8080` | Memcached management  |
| OpCache           | `http://opcache.localhost:8080`           | OpCache monitoring    |
| Kafbat            | `http://kafbat.localhost:8080`            | Kafka management      |

**Healthcheck**: `http://localhost:8080/health`

## 📊 How It Works

### 1. Base Image (Docker Hub)

- Minimal PHP 8.2 FPM + Nginx + Supervisor
- All PHP extensions pre-installed (mysqli, pdo, pgsql, redis, mongodb, memcached)
- Java runtime (for Kafbat)
- **No tools pre-installed** (~450MB)

### 2. Runtime Installation (Container Start)

When container starts, `entrypoint.sh`:

1. Reads environment variables
2. Downloads and installs selected tools
3. Generates Nginx configuration
4. Generates Supervisord configuration
5. Starts services (PHP-FPM, Nginx, Kafbat if enabled)

### 3. Persistent Storage (Optional)

Use volume to persist installed tools:

```yaml
volumes:
  - tools-data:/var/www/html
```

**Benefits**:

- Tools downloaded only once
- Faster subsequent startups (~5 seconds)
- No re-downloading on container restart

## ⏱️ Startup Time

### First Start (No Volume)

```
1. Docker pull: ~30 seconds (450MB image)
2. Container start
3. Tool installation:
   - Adminer: ~2 seconds
   - PhpMyAdmin: ~30 seconds
   - PhpPgAdmin: ~15 seconds
   - PhpMongo: ~45 seconds (git clone + composer)
   - Kafbat: ~20 seconds
4. Config generation: ~1 second
5. Services start: ~2 seconds

TOTAL: 1-3 minutes (depending on tools selected)
```

### Subsequent Starts (With Volume)

```
1. Container start: ~2 seconds
2. Tools already installed (skip)
3. Config generation: ~1 second
4. Services start: ~2 seconds

TOTAL: ~5 seconds
```

## 🎨 Example Configurations

### Minimal (Adminer Only)

```yaml
environment:
  TOOLS_ADMINER_ENABLE: "true"
# Startup: ~30 seconds
# Disk: ~500KB
```

### MySQL Stack

```yaml
environment:
  TOOLS_ADMINER_ENABLE: "true"
  TOOLS_PHPMYADMIN_ENABLE: "true"
# Startup: ~1 minute
# Disk: ~15MB
```

### Full Stack

```yaml
environment:
  TOOLS_ADMINER_ENABLE: "true"
  TOOLS_PHPMYADMIN_ENABLE: "true"
  TOOLS_PHPPGADMIN_ENABLE: "true"
  TOOLS_PHPMONGO_ENABLE: "true"
  TOOLS_PHPMEMCACHEDADMIN_ENABLE: "true"
  TOOLS_OPCACHE_ENABLE: "true"
  TOOLS_KAFBAT_ENABLE: "true"
# Startup: ~3 minutes
# Disk: ~80MB
```

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│         Nginx (Port 80)                 │
│  ┌──────────────────────────────────┐   │
│  │  Subdomain Routing               │   │
│  │  adminer.* → /var/www/html/...   │   │
│  │  phpmyadmin.* → /var/www/html/...│   │
│  └──────────────────────────────────┘   │
│                                         │
│  ┌──────────────────────────────────┐   │
│  │  PHP-FPM (Port 9000)             │   │
│  │  - Adminer                       │   │
│  │  - PhpMyAdmin                    │   │
│  │  - PhpPgAdmin                    │   │
│  │  - PhpMongo                      │   │
│  │  - PhpMemcachedAdmin             │   │
│  │  - OpCache                       │   │
│  └──────────────────────────────────┘   │
│                                         │
│  ┌──────────────────────────────────┐   │
│  │  Kafbat (Port 8080)              │   │
│  │  Java-based Kafka UI             │   │
│  └──────────────────────────────────┘   │
└─────────────────────────────────────────┘
           │
           ▼
    Supervisord (Process Manager)
```

## 🔍 Troubleshooting

### Tools not installing

Check container logs:

```bash
docker logs stackvo-tools
```

Look for download errors or network issues.

### Slow first startup

This is normal! Tools are being downloaded from the internet. Use persistent volume to avoid re-downloading.

### Tool not accessible

1. Check if tool is enabled: `docker exec stackvo-tools ls /var/www/html`
2. Check Nginx config: `docker exec stackvo-tools cat /etc/nginx/nginx.conf`
3. Check container logs: `docker logs stackvo-tools`

## 📝 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🔗 Links

- **GitHub Repository**: https://github.com/stackvo/stackvo-tools
- **Docker Hub**: https://hub.docker.com/r/stackvo/tools
- **Main Stackvo Project**: https://github.com/stackvo/stackvo
- **Issues**: https://github.com/stackvo/stackvo-tools/issues

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 💬 Support

For support, please open an issue on GitHub or contact the Stackvo team.
