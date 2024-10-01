#!/bin/bash
# 安装Nginx和Nginx Extras
apt install -y nginx nginx-extras

# 提示用户输入IP地址
read -p "请输入要转发的IP地址: " ip_address

# /etc/nginx/nginx.conf
config_path="/etc/nginx/nginx.conf"

# 检查文件是否存在，如果存在则删除
if [ -f "$config_path" ]; then
    rm -f "$config_path"
    echo "已删除现有的 $config_path 文件。"
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
    }

    server {
        listen 500;
        listen 500 udp;  # 监听UDP端口
        proxy_pass 500_backend;
    }

    server {
        listen 4500;
        listen 4500 udp;  # 监听UDP端口
        proxy_pass 4500_backend;
    }

    server {
        listen 1234;  # 监听TCP端口
        listen 1234 udp;  # 监听UDP端口
        proxy_pass 1234_backend;
    }

    server {
        listen 1116;  # 监听TCP端口
        listen 1116 udp;  # 监听UDP端口
        proxy_pass 1116_backend;
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


# 确保 /etc/nginx 目录存在
mkdir -p /etc/nginx

# 创建新的 nginx.conf 文件
echo "$config_content" > "$config_path"
echo "nginx反向代理配置已创建并保存到 $config_path"

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
