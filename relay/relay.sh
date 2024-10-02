#!/bin/bash
# 安装Nginx和Nginx Extras
apt install -y nginx nginx-extras

# 提示用户输入IP地址
read -p "请输入要转发的IP地址: " ip_address

# /etc/nginx/nginx.conf
config_path="/etc/nginx/nginx.conf"
available_path="/etc/nginx/sites-available/default"
enabled_path="/etc/nginx/sites-enabled/default"

# 检查文件是否存在，如果存在则删除
if [ -f "$config_path" ]; then
    rm -f "$config_path"
    echo "已删除现有的 $config_path 文件。"
fi

if [ -f "$available_path" ]; then
    rm -f "$available_path"
    echo "已删除现有的 $available_path 文件。"
fi

if [ -f "$enabled_path" ]; then
    rm -f "$enabled_path"
    echo "已删除现有的 $enabled_path 文件。"
fi


# 创建新的 config.json 内容
config_content=$(cat <<EOF
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
	worker_connections 768;
	# multi_accept on;
}

stream {
    upstream 1701_backend {
        server $ip_address:1701;
    }

    upstream 500_backend {
        server $ip_address:500;
    }

    upstream 4500_backend {
        server $ip_address:4500;
    }

    upstream 1234_backend {
        server $ip_address:1234;
    }
    
    upstream 1116_backend {
        server $ip_address:1116;
    }

    server {
        listen 1701;
        listen 1701 udp;  # 监听UDP端口
        proxy_pass 1701_backend;
        proxy_timeout 6000m;  # 增加超时时间为600分钟
        proxy_connect_timeout 600s;  # 连接超时60秒
        proxy_send_timeout 6000m;  # 发送数据超时时间
        proxy_read_timeout 6000m;  # 读取数据超时时间
    }

    server {
        listen 500;
        listen 500 udp;  # 监听UDP端口
        proxy_pass 500_backend;
        proxy_timeout 6000m;
        proxy_connect_timeout 600s;
        proxy_send_timeout 6000m;
        proxy_read_timeout 6000m;
    }

    server {
        listen 4500;
        listen 4500 udp;  # 监听UDP端口
        proxy_pass 4500_backend;
        proxy_timeout 6000m;
        proxy_connect_timeout 600s;
        proxy_send_timeout 6000m;
        proxy_read_timeout 6000m;
    }

    server {
        listen 1234;  # 监听TCP端口
        listen 1234 udp;  # 监听UDP端口
        proxy_pass 1234_backend;
        proxy_timeout 6000m;
        proxy_connect_timeout 600s;
        proxy_send_timeout 6000m;
        proxy_read_timeout 6000m;
    }

    server {
        listen 1116;  # 监听TCP端口
        listen 1116 udp;  # 监听UDP端口
        proxy_pass 1116_backend;
        proxy_timeout 6000m;
        proxy_connect_timeout 600s;
        proxy_send_timeout 6000m;
        proxy_read_timeout 6000m;
    }
}

http {

	##
	# Basic Settings
	##

	sendfile on;
	tcp_nopush on;
	types_hash_max_size 2048;
	# server_tokens off;

	# server_names_hash_bucket_size 64;
	# server_name_in_redirect off;

	include /etc/nginx/mime.types;
	default_type application/octet-stream;

	##
	# SSL Settings
	##

	ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3; # Dropping SSLv3, ref: POODLE
	ssl_prefer_server_ciphers on;

	##
	# Logging Settings
	##

	access_log /var/log/nginx/access.log;
	error_log /var/log/nginx/error.log;

	##
	# Gzip Settings
	##

	gzip on;

	# gzip_vary on;
	# gzip_proxied any;
	# gzip_comp_level 6;
	# gzip_buffers 16 8k;
	# gzip_http_version 1.1;
	# gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

	##
	# Virtual Host Configs
	##

	include /etc/nginx/conf.d/*.conf;
	include /etc/nginx/sites-enabled/*;
}


#mail {
#	# See sample authentication script at:
#	# http://wiki.nginx.org/ImapAuthenticateWithApachePhpScript
#
#	# auth_http localhost/auth.php;
#	# pop3_capabilities "TOP" "USER";
#	# imap_capabilities "IMAP4rev1" "UIDPLUS";
#
#	server {
#		listen     localhost:110;
#		protocol   pop3;
#		proxy      on;
#	}
#
#	server {
#		listen     localhost:143;
#		protocol   imap;
#		proxy      on;
#	}
#}

EOF
)

available_content=$(cat <<EOF
##
# You should look at the following URL's in order to grasp a solid understanding
# of Nginx configuration files in order to fully unleash the power of Nginx.
# https://www.nginx.com/resources/wiki/start/
# https://www.nginx.com/resources/wiki/start/topics/tutorials/config_pitfalls/
# https://wiki.debian.org/Nginx/DirectoryStructure
#
# In most cases, administrators will remove this file from sites-enabled/ and
# leave it as reference inside of sites-available where it will continue to be
# updated by the nginx packaging team.
#
# This file will automatically load configuration files provided by other
# applications, such as Drupal or Wordpress. These applications will be made
# available underneath a path with that package name, such as /drupal8.
#
# Please see /usr/share/doc/nginx-doc/examples/ for more detailed examples.
##

# Default server configuration
#
server {
	listen 8765 default_server;
	listen [::]:8765 default_server;

	# SSL configuration
	#
	# listen 443 ssl default_server;
	# listen [::]:443 ssl default_server;
	#
	# Note: You should disable gzip for SSL traffic.
	# See: https://bugs.debian.org/773332
	#
	# Read up on ssl_ciphers to ensure a secure configuration.
	# See: https://bugs.debian.org/765782
	#
	# Self signed certs generated by the ssl-cert package
	# Don't use them in a production server!
	#
	# include snippets/snakeoil.conf;

	root /var/www/html;

	# Add index.php to the list if you are using PHP
	index index.html index.htm index.nginx-debian.html;

	server_name _;

	location / {
		# First attempt to serve request as file, then
		# as directory, then fall back to displaying a 404.
		try_files $uri $uri/ =404;
	}

	# pass PHP scripts to FastCGI server
	#
	#location ~ \.php$ {
	#	include snippets/fastcgi-php.conf;
	#
	#	# With php-fpm (or other unix sockets):
	#	fastcgi_pass unix:/run/php/php7.4-fpm.sock;
	#	# With php-cgi (or other tcp sockets):
	#	fastcgi_pass 127.0.0.1:9000;
	#}

	# deny access to .htaccess files, if Apache's document root
	# concurs with nginx's one
	#
	#location ~ /\.ht {
	#	deny all;
	#}
}


# Virtual Host configuration for example.com
#
# You can move that to a different file under sites-available/ and symlink that
# to sites-enabled/ to enable it.
#
#server {
#	listen 80;
#	listen [::]:80;
#
#	server_name example.com;
#
#	root /var/www/example.com;
#	index index.html;
#
#	location / {
#		try_files $uri $uri/ =404;
#	}
#}

EOF
)

enabled_content=$(cat <<EOF
##
# You should look at the following URL's in order to grasp a solid understanding
# of Nginx configuration files in order to fully unleash the power of Nginx.
# https://www.nginx.com/resources/wiki/start/
# https://www.nginx.com/resources/wiki/start/topics/tutorials/config_pitfalls/
# https://wiki.debian.org/Nginx/DirectoryStructure
#
# In most cases, administrators will remove this file from sites-enabled/ and
# leave it as reference inside of sites-available where it will continue to be
# updated by the nginx packaging team.
#
# This file will automatically load configuration files provided by other
# applications, such as Drupal or Wordpress. These applications will be made
# available underneath a path with that package name, such as /drupal8.
#
# Please see /usr/share/doc/nginx-doc/examples/ for more detailed examples.
##

# Default server configuration
#
server {
	listen 8765 default_server;
	listen [::]:8765 default_server;

	# SSL configuration
	#
	# listen 443 ssl default_server;
	# listen [::]:443 ssl default_server;
	#
	# Note: You should disable gzip for SSL traffic.
	# See: https://bugs.debian.org/773332
	#
	# Read up on ssl_ciphers to ensure a secure configuration.
	# See: https://bugs.debian.org/765782
	#
	# Self signed certs generated by the ssl-cert package
	# Don't use them in a production server!
	#
	# include snippets/snakeoil.conf;

	root /var/www/html;

	# Add index.php to the list if you are using PHP
	index index.html index.htm index.nginx-debian.html;

	server_name _;

	location / {
		# First attempt to serve request as file, then
		# as directory, then fall back to displaying a 404.
		try_files $uri $uri/ =404;
	}

	# pass PHP scripts to FastCGI server
	#
	#location ~ \.php$ {
	#	include snippets/fastcgi-php.conf;
	#
	#	# With php-fpm (or other unix sockets):
	#	fastcgi_pass unix:/run/php/php7.4-fpm.sock;
	#	# With php-cgi (or other tcp sockets):
	#	fastcgi_pass 127.0.0.1:9000;
	#}

	# deny access to .htaccess files, if Apache's document root
	# concurs with nginx's one
	#
	#location ~ /\.ht {
	#	deny all;
	#}
}


# Virtual Host configuration for example.com
#
# You can move that to a different file under sites-available/ and symlink that
# to sites-enabled/ to enable it.
#
#server {
#	listen 80;
#	listen [::]:80;
#
#	server_name example.com;
#
#	root /var/www/example.com;
#	index index.html;
#
#	location / {
#		try_files $uri $uri/ =404;
#	}
#}

EOF
)


# 确保 /etc/nginx 目录存在
mkdir -p /etc/nginx

# 创建新的 nginx.conf 文件
echo "$config_content" > "$config_path"
echo "nginx反向代理配置已创建并保存到 $config_path"

# 创建新的 available 文件
echo "$enabled_content" > "$enabled_path"
echo "新的 available 已创建并保存到 $enabled_path"

# 创建新的 enabled 文件
echo "$enabled_content" > "$enabled_path"
echo "新的 enabled 已创建并保存到 $enabled_path"

# 杀死nginx
killall nginx

# 重新启动 nginx 服务
nginx

# 检查服务状态
if [ $? -eq 0 ]; then
    echo "gost 服务已成功重启。"
else
    echo "gost 服务重启失败，请检查配置文件和服务状态。"
fi
