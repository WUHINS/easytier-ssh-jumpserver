# 项目已推送到 GitHub

## ✅ 推送成功

项目已成功推送到 GitHub 仓库：

**仓库地址**: https://github.com/WUHINS/easytier-ssh-jumpserver

**分支**: `main`

**提交**: `c94c708` - Initial commit: EasyTier SSH Jumpserver with Web Console support

---

## 📦 项目结构

```
easytier-ssh-jumpserver/
├── .github/
│   └── workflows/
│       └── build.yml          # GitHub Actions 工作流
├── scripts/
│   ├── entrypoint.sh          # 容器启动脚本
│   └── init-ssh.sh            # SSH 初始化脚本
├── .env.example               # 环境变量示例
├── .gitignore                 # Git 忽略文件
├── .git/                      # Git 仓库
├── build.sh                   # 构建脚本
├── deploy.sh                  # 部署脚本
├── docker-compose.yml         # Docker Compose 配置
├── Dockerfile                 # Docker 镜像构建文件
├── GITHUB_ACTIONS.md          # GitHub Actions 使用指南
├── LICENSE                    # LGPL-3.0 许可证
├── README.md                  # 项目主文档
├── QUICKSTART.md              # 快速开始指南
└── VERSIONING.md              # 版本管理文档
```

---

## 🚀 下一步操作

### 1. 配置 GitHub Secrets

**好消息**: 不需要额外配置 Secrets！

GitHub Container Registry (GHCR) 使用自动生成的 `GITHUB_TOKEN` 进行认证。

工作流会自动使用 `${{ secrets.GITHUB_TOKEN }}` 登录 GHCR，无需手动配置 Docker Hub 凭证。

### 2. 测试 GitHub Actions

#### 自动触发
```bash
# 推送到 main 分支会自动触发构建
git push origin main
```

#### 手动触发
1. 访问：https://github.com/WUHINS/easytier-ssh-jumpserver/actions
2. 选择 **Build and Push Docker Image** 工作流
3. 点击 **Run workflow**
4. 填写参数并运行

### 3. 创建版本标签

```bash
# 创建版本标签
git tag v2.5.0

# 推送标签（会自动触发构建）
git push origin v2.5.0
```

---

## 📋 GitHub Actions 工作流说明

### 触发条件

1. **Push 到 main 分支**
   - 自动构建并推送 `latest` 标签镜像

2. **创建版本标签（v*）**
   - 自动构建并推送对应版本标签镜像

3. **手动触发（Workflow Dispatch）**
   - 可在 GitHub 网站上手动运行
   - 支持自定义参数：
     - `version`: 版本标签
     - `push_to_registry`: 是否推送到镜像仓库
     - `platforms`: 构建平台

### 3. 构建的镜像

- **GitHub Container Registry**: `ghcr.io/wuhins/easytier-ssh-jumpserver`
  - 访问地址：https://github.com/WUHINS/easytier-ssh-jumpserver/pkgs/container/easytier-ssh-jumpserver

### 镜像标签规则

- `latest`: 最新稳定版
- `v2.5.0`: 特定版本号
- `v2`: 主版本号
- `v2.5`: 次版本号

---

## 🔧 本地使用

### 构建镜像

```bash
cd easytier-ssh-jumpserver

# 使用 build.sh 脚本构建
./build.sh build

# 或使用 docker-compose 构建
docker-compose build
```

### 运行容器

```bash
# 使用 docker-compose
docker-compose up -d

# 或使用 docker run
docker run -d \
  --name easytier-ssh \
  --privileged \
  --network host \
  -e ET_CONFIG_SERVER=ws://api.easytier.hinswu.top:0/HINS \
  -e ET_MACHINE_ID=HINS-UZ801-SSH01 \
  -e SSH_PASSWORD=YourSecurePassword123 \
  easytier-ssh-jumpserver:latest
```

---

## 📖 文档

- **[README.md](./README.md)**: 项目主文档
- **[QUICKSTART.md](./QUICKSTART.md)**: 快速开始指南
- **[VERSIONING.md](./VERSIONING.md)**: 版本管理
- **[GITHUB_ACTIONS.md](./GITHUB_ACTIONS.md)**: GitHub Actions 使用指南

---

## 🎯 项目特性

- ✅ 基于 EasyTier 去中心化虚拟网络
- ✅ 支持通过 `ET_CONFIG_SERVER` 连接 Web Console
- ✅ 支持 `ET_MACHINE_ID` 机器标识
- ✅ 支持密码和 SSH 公钥认证
- ✅ 一键部署脚本
- ✅ 自动 GitHub Actions 构建
- ✅ 多架构支持 (x86_64, ARM64, ARMv7)
- ✅ Docker 镜像版本与 EasyTier Core 保持一致
- ✅ 启动日志第一条显示版本信息

---

## 📊 项目状态

- [x] 代码已提交到 GitHub
- [x] 已推送到 main 分支
- [x] GitHub Actions 工作流已配置
- [x] 支持手动触发工作流
- [ ] 需要配置 Docker Hub Secrets
- [ ] 需要测试自动构建
- [ ] 需要创建第一个版本标签

---

## 🔗 相关链接

- **GitHub 仓库**: https://github.com/WUHINS/easytier-ssh-jumpserver
- **GitHub Actions**: https://github.com/WUHINS/easytier-ssh-jumpserver/actions
- **Docker Hub**: https://hub.docker.com/r/wuhins/easytier-ssh-jumpserver
- **EasyTier 官方**: https://github.com/EasyTier/EasyTier

---

**推送时间**: 2024
**当前版本**: v2.5.0
**状态**: ✅ 已成功推送到 GitHub
