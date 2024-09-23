#!/bin/bash

# 下载 ajiasu 可执行文件并存放到 /usr/local/bin
curl -L -o /usr/local/bin/ajiasu https://github.moeyy.xyz/https://raw.githubusercontent.com/PainterXIII/YouRan_Proxy/master/ajiasu/ajiasu

# 给予可执行权限
chmod +x /usr/local/bin/ajiasu

# 下载 ajiasu 配置文件并存放到 /etc
curl -L -o /etc/ajiasu.conf https://github.moeyy.xyz/https://raw.githubusercontent.com/PainterXIII/YouRan_Proxy/master/ajiasu/ajiasu.conf

# 登录 ajiasu
ajiasu login

# 启动5个 ajiasu connect 并确保其在后台运行，SSH断开也不会终止
for i in {1..5}; do
    nohup bash -c '
    while true; do
        ajiasu connect
        if [ $? -ne 0 ]; then
            echo "ajiasu 连接失败，正在重启..."
            sleep 5
        else
            echo "ajiasu 已成功连接"
            break
        fi
    done' > /dev/null 2>&1 &
done

# 确保运行5个后台进程
echo "5 个 ajiasu connect 已在后台启动"
