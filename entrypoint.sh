#!/bin/bash
###################################################################
# STACKVO TOOLS - RUNTIME INSTALLATION ENTRYPOINT
# Dynamically installs tools based on environment variables
###################################################################

set -e

echo "🚀 Stackvo Tools Container Starting..."
echo "📦 Runtime Installation Mode"

# ===================================================================
# ENVIRONMENT VARIABLES
# ===================================================================

# Tool enable flags
ADMINER_ENABLED=${TOOLS_ADMINER_ENABLE:-false}
PHPMYADMIN_ENABLED=${TOOLS_PHPMYADMIN_ENABLE:-false}
PHPPGADMIN_ENABLED=${TOOLS_PHPPGADMIN_ENABLE:-false}
PHPMONGO_ENABLED=${TOOLS_PHPMONGO_ENABLE:-false}
PHPMEMCACHEDADMIN_ENABLED=${TOOLS_PHPMEMCACHEDADMIN_ENABLE:-false}
OPCACHE_ENABLED=${TOOLS_OPCACHE_ENABLE:-false}
KAFBAT_ENABLED=${TOOLS_KAFBAT_ENABLE:-false}

# Tool versions
ADMINER_VERSION=${TOOLS_ADMINER_VERSION:-4.8.1}
PHPMYADMIN_VERSION=${TOOLS_PHPMYADMIN_VERSION:-5.2.1}
PHPPGADMIN_VERSION=${TOOLS_PHPPGADMIN_VERSION:-7.13.0}
PHPMONGO_VERSION=${TOOLS_PHPMONGO_VERSION:-1.3.3}
PHPMEMCACHEDADMIN_VERSION=${TOOLS_PHPMEMCACHEDADMIN_VERSION:-1.3.0}
OPCACHE_VERSION=${TOOLS_OPCACHE_VERSION:-3.6.0}
KAFBAT_VERSION=${TOOLS_KAFBAT_VERSION:-1.4.2}

# ===================================================================
# TOOL INSTALLATION (Runtime)
# ===================================================================

cd /var/www/html

# Check if tools are already installed (persistent volume)
if [ -f "/var/www/html/.tools_installed" ]; then
    echo "✅ Tools already installed (using persistent volume)"
    SKIP_INSTALLATION=true
else
    echo "📦 Installing tools..."
    SKIP_INSTALLATION=false
fi

# --- 1. Adminer ---
if [ "$ADMINER_ENABLED" = "true" ] && [ "$SKIP_INSTALLATION" = "false" ]; then
    echo "  📥 Installing Adminer v${ADMINER_VERSION}..."
    mkdir -p adminer
    curl -sL -o adminer/index.php \
        "https://github.com/vrana/adminer/releases/download/v${ADMINER_VERSION}/adminer-${ADMINER_VERSION}.php"
    echo "  ✅ Adminer installed"
fi

# --- 2. PhpMyAdmin ---
if [ "$PHPMYADMIN_ENABLED" = "true" ] && [ "$SKIP_INSTALLATION" = "false" ]; then
    echo "  📥 Installing PhpMyAdmin v${PHPMYADMIN_VERSION}..."
    curl -sL "https://files.phpmyadmin.net/phpMyAdmin/${PHPMYADMIN_VERSION}/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.zip" -o pma.zip
    unzip -q pma.zip
    mv "phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages" phpmyadmin
    rm pma.zip
    
    # Configure
    cp phpmyadmin/config.sample.inc.php phpmyadmin/config.inc.php
    sed -i "s/\$cfg\['blowfish_secret'\] = '';/\$cfg['blowfish_secret'] = 'stackvo-secret-key-12345678901234567890';/" phpmyadmin/config.inc.php
    cat >> phpmyadmin/config.inc.php <<EOF

\$cfg['Servers'][\$i]['host'] = 'stackvo-mysql';
\$cfg['Servers'][\$i]['port'] = '3306';
\$cfg['Servers'][\$i]['auth_type'] = 'cookie';
\$cfg['AllowArbitraryServer'] = true;
EOF
    echo "  ✅ PhpMyAdmin installed"
fi

# --- 3. PhpPgAdmin ---
if [ "$PHPPGADMIN_ENABLED" = "true" ] && [ "$SKIP_INSTALLATION" = "false" ]; then
    echo "  📥 Installing PhpPgAdmin v${PHPPGADMIN_VERSION}..."
    curl -sL "https://github.com/phppgadmin/phppgadmin/releases/download/REL_7-13-0/phpPgAdmin-${PHPPGADMIN_VERSION}.zip" -o ppa.zip
    unzip -q ppa.zip
    mv "phpPgAdmin-${PHPPGADMIN_VERSION}" phppgadmin
    rm ppa.zip
    
    # Configure
    cp phppgadmin/conf/config.inc.php-dist phppgadmin/conf/config.inc.php
    sed -i "s/\$conf\['servers'\]\[0\]\['host'\] = '';/\$conf['servers'][0]['host'] = 'stackvo-postgres';/" phppgadmin/conf/config.inc.php
    echo "  ✅ PhpPgAdmin installed"
fi

# --- 4. MongoDB-PHP-GUI ---
if [ "$PHPMONGO_ENABLED" = "true" ] && [ "$SKIP_INSTALLATION" = "false" ]; then
    echo "  📥 Installing MongoDB-PHP-GUI v${PHPMONGO_VERSION}..."
    git clone --depth 1 https://github.com/SamuelTallet/MongoDB-PHP-GUI.git phpmongo
    cd phpmongo
    composer install --no-dev --optimize-autoloader --quiet
    
    # Configure
    cat > config.php <<EOF
<?php
define('MONGO_HOST', 'stackvo-mongo');
define('MONGO_PORT', 27017);
define('MONGO_USER', 'root');
define('MONGO_PASS', 'root');
define('MONGO_AUTH_DB', 'admin');
EOF
    cd /var/www/html
    echo "  ✅ MongoDB-PHP-GUI installed"
fi

# --- 5. PhpMemcachedAdmin ---
if [ "$PHPMEMCACHEDADMIN_ENABLED" = "true" ] && [ "$SKIP_INSTALLATION" = "false" ]; then
    echo "  📥 Installing PhpMemcachedAdmin v${PHPMEMCACHEDADMIN_VERSION}..."
    mkdir -p phpmemcachedadmin
    curl -sL https://github.com/elijaa/phpmemcachedadmin/archive/refs/heads/master.zip -o pma_mem.zip
    unzip -q pma_mem.zip
    mv phpmemcachedadmin-master/* phpmemcachedadmin/
    rm -rf phpmemcachedadmin-master pma_mem.zip
    echo "  ✅ PhpMemcachedAdmin installed"
fi

# --- 6. OpCacheGUI ---
if [ "$OPCACHE_ENABLED" = "true" ] && [ "$SKIP_INSTALLATION" = "false" ]; then
    echo "  📥 Installing OpCacheGUI v${OPCACHE_VERSION}..."
    mkdir -p opcache
    curl -sL https://raw.githubusercontent.com/amnuts/opcache-gui/master/index.php -o opcache/index.php
    echo "  ✅ OpCacheGUI installed"
fi

# --- 7. Kafbat Kafka UI ---
if [ "$KAFBAT_ENABLED" = "true" ] && [ "$SKIP_INSTALLATION" = "false" ]; then
    echo "  📥 Installing Kafbat Kafka UI v${KAFBAT_VERSION}..."
    curl -sL "https://github.com/kafbat/kafka-ui/releases/download/v${KAFBAT_VERSION}/kafka-ui-api-v${KAFBAT_VERSION}.jar" \
        -o /opt/kafbat/kafka-ui.jar
    echo "  ✅ Kafbat Kafka UI installed"
fi

# Mark installation complete
if [ "$SKIP_INSTALLATION" = "false" ]; then
    touch /var/www/html/.tools_installed
    echo "✅ All tools installed successfully"
fi

# Fix permissions
chown -R www-data:www-data /var/www/html

# ===================================================================
# GENERATE NGINX CONFIGURATION (Runtime)
# ===================================================================

echo "⚙️  Generating Nginx configuration..."

cat > /etc/nginx/nginx.conf <<'NGINX_CONFIG'
worker_processes 1;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    # Healthcheck server (always enabled)
    server {
        listen 80 default_server;
        server_name _;
        
        location = /health {
            access_log off;
            return 200 "OK\n";
            add_header Content-Type text/plain;
        }
        
        location / {
            return 404 "Not Found\n";
            add_header Content-Type text/plain;
        }
    }
NGINX_CONFIG

# Add Adminer server block
if [ "$ADMINER_ENABLED" = "true" ]; then
    cat >> /etc/nginx/nginx.conf <<'NGINX_CONFIG'
    
    # Adminer
    server {
        listen 80;
        server_name adminer.*;
        root /var/www/html/adminer;
        index index.php;
        
        location / {
            try_files $uri $uri/ /index.php?$query_string;
        }
        
        location ~ \.php$ {
            fastcgi_pass 127.0.0.1:9000;
            fastcgi_index index.php;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        }
    }
NGINX_CONFIG
fi

# Add PhpMyAdmin server block
if [ "$PHPMYADMIN_ENABLED" = "true" ]; then
    cat >> /etc/nginx/nginx.conf <<'NGINX_CONFIG'
    
    # PhpMyAdmin
    server {
        listen 80;
        server_name phpmyadmin.*;
        root /var/www/html/phpmyadmin;
        index index.php;
        
        location / {
            try_files $uri $uri/ /index.php?$query_string;
        }
        
        location ~ \.php$ {
            fastcgi_pass 127.0.0.1:9000;
            fastcgi_index index.php;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        }
    }
NGINX_CONFIG
fi

# Add PhpPgAdmin server block
if [ "$PHPPGADMIN_ENABLED" = "true" ]; then
    cat >> /etc/nginx/nginx.conf <<'NGINX_CONFIG'
    
    # PhpPgAdmin
    server {
        listen 80;
        server_name phppgadmin.*;
        root /var/www/html/phppgadmin;
        index index.php;
        
        location / {
            try_files $uri $uri/ /index.php?$query_string;
        }
        
        location ~ \.php$ {
            fastcgi_pass 127.0.0.1:9000;
            fastcgi_index index.php;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        }
    }
NGINX_CONFIG
fi

# Add PhpMongo server block
if [ "$PHPMONGO_ENABLED" = "true" ]; then
    cat >> /etc/nginx/nginx.conf <<'NGINX_CONFIG'
    
    # MongoDB-PHP-GUI
    server {
        listen 80;
        server_name phpmongo.*;
        root /var/www/html/phpmongo;
        index index.php;
        
        location / {
            try_files $uri $uri/ /index.php?$query_string;
        }
        
        location ~ \.php$ {
            fastcgi_pass 127.0.0.1:9000;
            fastcgi_index index.php;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        }
    }
NGINX_CONFIG
fi

# Add PhpMemcachedAdmin server block
if [ "$PHPMEMCACHEDADMIN_ENABLED" = "true" ]; then
    cat >> /etc/nginx/nginx.conf <<'NGINX_CONFIG'
    
    # PhpMemcachedAdmin
    server {
        listen 80;
        server_name phpmemcachedadmin.*;
        root /var/www/html/phpmemcachedadmin;
        index index.php;
        
        location / {
            try_files $uri $uri/ /index.php?$query_string;
        }
        
        location ~ \.php$ {
            fastcgi_pass 127.0.0.1:9000;
            fastcgi_index index.php;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        }
    }
NGINX_CONFIG
fi

# Add OpCache server block
if [ "$OPCACHE_ENABLED" = "true" ]; then
    cat >> /etc/nginx/nginx.conf <<'NGINX_CONFIG'
    
    # OpCacheGUI
    server {
        listen 80;
        server_name opcache.*;
        root /var/www/html/opcache;
        index index.php;
        
        location / {
            try_files $uri $uri/ /index.php?$query_string;
        }
        
        location ~ \.php$ {
            fastcgi_pass 127.0.0.1:9000;
            fastcgi_index index.php;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        }
    }
NGINX_CONFIG
fi

# Add Kafbat server block (reverse proxy to Java app)
if [ "$KAFBAT_ENABLED" = "true" ]; then
    cat >> /etc/nginx/nginx.conf <<'NGINX_CONFIG'
    
    # Kafbat Kafka UI
    server {
        listen 80;
        server_name kafbat.*;
        
        location / {
            proxy_pass http://127.0.0.1:8080;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
NGINX_CONFIG
fi

# Close http block
echo "}" >> /etc/nginx/nginx.conf

echo "✅ Nginx configuration generated"

# ===================================================================
# GENERATE SUPERVISORD CONFIGURATION (Runtime)
# ===================================================================

echo "⚙️  Generating Supervisord configuration..."

cat > /etc/supervisord.conf <<'SUPERVISOR_CONFIG'
[supervisord]
nodaemon=true
user=root
logfile=/var/log/supervisord.log
pidfile=/var/run/supervisord.pid

[program:php-fpm]
command=php-fpm -F
autostart=true
autorestart=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0

[program:nginx]
command=nginx -g 'daemon off;'
autostart=true
autorestart=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
SUPERVISOR_CONFIG

# Add Kafbat program
if [ "$KAFBAT_ENABLED" = "true" ]; then
    cat >> /etc/supervisord.conf <<'SUPERVISOR_CONFIG'

[program:kafbat]
command=java -jar /opt/kafbat/kafka-ui.jar
autostart=true
autorestart=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
environment=DYNAMIC_CONFIG_ENABLED="true",KAFKA_CLUSTERS_0_NAME="stackvo-kafka",KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS="stackvo-kafka:9092"
SUPERVISOR_CONFIG
fi

echo "✅ Supervisord configuration generated"

# ===================================================================
# START SERVICES
# ===================================================================

echo ""
echo "🎉 Configuration complete!"
echo "🚀 Starting services..."
echo ""
echo "Enabled tools:"
[ "$ADMINER_ENABLED" = "true" ] && echo "  ✅ Adminer v${ADMINER_VERSION}"
[ "$PHPMYADMIN_ENABLED" = "true" ] && echo "  ✅ PhpMyAdmin v${PHPMYADMIN_VERSION}"
[ "$PHPPGADMIN_ENABLED" = "true" ] && echo "  ✅ PhpPgAdmin v${PHPPGADMIN_VERSION}"
[ "$PHPMONGO_ENABLED" = "true" ] && echo "  ✅ MongoDB-PHP-GUI v${PHPMONGO_VERSION}"
[ "$PHPMEMCACHEDADMIN_ENABLED" = "true" ] && echo "  ✅ PhpMemcachedAdmin v${PHPMEMCACHEDADMIN_VERSION}"
[ "$OPCACHE_ENABLED" = "true" ] && echo "  ✅ OpCacheGUI v${OPCACHE_VERSION}"
[ "$KAFBAT_ENABLED" = "true" ] && echo "  ✅ Kafbat Kafka UI v${KAFBAT_VERSION}"
echo ""

# Start supervisord
exec /usr/bin/supervisord -c /etc/supervisord.conf
