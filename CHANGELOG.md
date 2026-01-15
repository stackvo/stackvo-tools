# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-01-15

### Added

- Initial release of Stackvo Tools Container
- Runtime installation approach (tools installed at container start)
- Support for 7 database and cache management tools:
  - Adminer v4.8.1
  - PhpMyAdmin v5.2.1
  - PhpPgAdmin v7.13.0
  - MongoDB-PHP-GUI v1.3.3
  - PhpMemcachedAdmin v1.3.0
  - OpCacheGUI v3.6.0
  - Kafbat Kafka UI v1.4.2
- Dynamic configuration via environment variables
- Persistent storage support (volume for installed tools)
- Subdomain-based routing (Nginx)
- Multi-process management (Supervisord)
- GitHub Actions CI/CD pipeline for automated builds
- Docker Hub integration for pre-built base images
- Multi-platform support (linux/amd64, linux/arm64)

### Technical Details

- Base: PHP 8.2 FPM Alpine
- Web Server: Nginx
- Process Manager: Supervisord
- PHP Extensions: mysqli, pdo, pdo_mysql, pdo_pgsql, pgsql, redis, mongodb, memcached, opcache
- Java Runtime: OpenJDK 21 JRE (for Kafbat)
- Base image size: ~450MB
- Startup time: 1-3 minutes (first start), ~5 seconds (subsequent starts with volume)

[Unreleased]: https://github.com/stackvo/stackvo-tools/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/stackvo/stackvo-tools/releases/tag/v1.0.0
