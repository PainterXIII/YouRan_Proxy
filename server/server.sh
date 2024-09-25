#!/bin/bash

# 1. 开启IP转发
echo "======== 开启IP转发 ========"
sysctl -w net.ipv4.ip_forward=1
echo "IP转发已开启"

# 2. 判断系统防火墙并关闭
echo "======== 判断防火墙并关闭 ========"

# 检查是否使用ufw防火墙
if command -v ufw &> /dev/null; then
    echo "检测到ufw防火墙，正在关闭..."
    ufw disable
    echo "ufw防火墙已关闭"
# 检查是否使用firewalld防火墙
elif command -v firewall-cmd &> /dev/null; then
    echo "检测到firewalld防火墙，正在关闭..."
    systemctl stop firewalld
    systemctl disable firewalld
    echo "firewalld防火墙已关闭"
else
    echo "未检测到已启用的防火墙服务"
fi

# 3. 更新系统包信息
echo "======== 更新包信息 ========"
apt update
echo "系统包信息已更新"

# 4. 安装vim和net-tools
echo "======== 安装vim ========"
apt install -y vim
echo "vim 已安装"

echo "======== 安装net-tools ========"
apt install -y net-tools
echo "net-tools 已安装"

echo "======== 脚本执行完毕 ========"
