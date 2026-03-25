#!/bin/bash

set -e

echo "=== Initializing SSH Configuration ==="

mkdir -p /root/.ssh
chmod 700 /root/.ssh

mkdir -p /var/run/sshd

# 生成 SSH 主机密钥（如果不存在）
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    echo "Generating SSH host keys..."
    ssh-keygen -A
fi

# 检查是否启用受限模式
if [ "$SSH_JUMPShell" = "true" ]; then
    echo "=== Enabling Restricted Jumpshell Mode ==="
    JUMP_SHELL_CONFIG="ForceCommand /jumpshell"
else
    JUMP_SHELL_CONFIG=""
fi

# 创建 sshd_config
cat > /etc/ssh/sshd_config << EOF
Port 22
PermitRootLogin yes
PasswordAuthentication yes
PubkeyAuthentication yes
ChallengeResponseAuthentication no
X11Forwarding no
PrintMotd no
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/ssh/sftp-server
AllowAgentForwarding yes
AllowTcpForwarding yes
$JUMP_SHELL_CONFIG
EOF

echo "SSH configuration created"

# 如果提供了密码，设置 root 密码
if [ -n "$SSH_PASSWORD" ]; then
    echo "root:$SSH_PASSWORD" | chpasswd
    echo "SSH password set for root user"
fi

# 检查 authorized_keys
if [ -f /root/.ssh/authorized_keys ]; then
    chmod 600 /root/.ssh/authorized_keys
    chown root:root /root/.ssh/authorized_keys
    echo "SSH authorized_keys configured"
fi

echo "=== SSH Initialization Complete ==="
