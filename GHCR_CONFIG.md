# GHCR 镜像推送配置说明

## ✅ 配置完成

GitHub Actions 工作流已优化为**只推送到 GitHub Container Registry (GHCR)**，并使用**仓库令牌自动认证**。

---

## 🎯 关键改进

### 1. **无需配置 Docker Hub Secrets**

❌ **之前**: 需要手动配置 `DOCKERHUB_USERNAME` 和 `DOCKERHUB_TOKEN`  
✅ **现在**: 使用 `${{ secrets.GITHUB_TOKEN }}` 自动认证

### 2. **只推送到 GHCR**

❌ **之前**: 同时推送到 Docker Hub 和 GHCR  
✅ **现在**: 只推送到 `ghcr.io/wuhins/easytier-ssh-jumpserver`

### 3. **自动认证**

工作流自动使用 GitHub 生成的 `GITHUB_TOKEN` 登录 GHCR，无需任何手动配置。

---

## 📦 镜像地址

**GitHub Container Registry**:
```
ghcr.io/wuhins/easytier-ssh-jumpserver:latest
ghcr.io/wuhins/easytier-ssh-jumpserver:v2.5.0
```

**访问地址**:
https://github.com/WUHINS/easytier-ssh-jumpserver/pkgs/container/easytier-ssh-jumpserver

---

## 🔧 工作流配置

### 触发条件

1. **Push 到 main 分支** → 自动构建 `latest` 标签
2. **创建版本标签** → 自动构建对应版本标签
3. **手动触发** → 可自定义参数

### 登录 GHCR

```yaml
- name: Login to GitHub Container Registry
  if: github.event_name != 'pull_request' && inputs.push_to_registry
  uses: docker/login-action@v3
  with:
    registry: ghcr.io
    username: ${{ github.actor }}
    password: ${{ secrets.GITHUB_TOKEN }}
```

### 构建镜像

```yaml
- name: Build and push
  uses: docker/build-push-action@v6
  with:
    context: ./build
    file: ./Dockerfile
    platforms: ${{ github.event.inputs.platforms || 'linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6' }}
    push: ${{ github.event_name != 'pull_request' && (github.event.inputs.push_to_registry != 'false' || github.event_name != 'workflow_dispatch') }}
    tags: ${{ steps.meta.outputs.tags }}
    labels: ${{ steps.meta.outputs.labels }}
    cache-from: type=gha
    cache-to: type=gha,mode=max
```

---

## 🚀 使用方式

### 自动触发

```bash
# Push 到 main 分支
git push origin main

# 创建版本标签
git tag v2.5.0
git push origin v2.5.0
```

### 手动触发

1. 访问：https://github.com/WUHINS/easytier-ssh-jumpserver/actions
2. 选择 "Build and Push Docker Image"
3. 点击 "Run workflow"
4. 填写参数：
   - **Version tag**: `v2.5.0` 或 `latest`
   - **Push to registry**: `true` (默认)
   - **Platforms**: `linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6` (默认)
5. 点击 "Run workflow"

---

## 📋 镜像标签规则

| 触发条件 | 生成的标签 |
|---------|-----------|
| Push to main | `latest` |
| Tag v2.5.0 | `v2.5.0`, `v2`, `v2.5` |
| Manual (version=v3.0.0) | `v3.0.0` |

---

## 🔐 权限说明

### GITHUB_TOKEN 权限

`GITHUB_TOKEN` 是 GitHub 自动生成的令牌，具有以下权限：

- ✅ 读取仓库代码
- ✅ 写入 GHCR 镜像
- ✅ 访问 Actions 运行时数据
- ✅ 有效期：仅在工作流运行期间有效

### 包可见性

默认情况下，GHCR 包的可见性与仓库一致：

- **公共仓库** → 公开镜像（任何人都可以拉取）
- **私有仓库** → 私有镜像（需要认证才能拉取）

修改包可见性：
https://github.com/WUHINS/easytier-ssh-jumpserver/pkgs/container/easytier-ssh-jumpserver

---

## 🎉 优势

### 1. **零配置**
- 无需注册 Docker Hub
- 无需创建 Access Token
- 无需配置 Secrets

### 2. **更安全**
- 使用临时令牌（GITHUB_TOKEN）
- 令牌自动轮换
- 无长期凭证泄露风险

### 3. **更集成**
- 与 GitHub 用户/组织深度集成
- 包与仓库关联
- 统一的权限管理

### 4. **免费额度**
- 免费存储：500 MB
- 免费带宽：50 GB/月
- 对于个人项目通常够用

---

## 📊 拉取镜像

### 本地拉取

```bash
# 拉取最新版
docker pull ghcr.io/wuhins/easytier-ssh-jumpserver:latest

# 拉取特定版本
docker pull ghcr.io/wuhins/easytier-ssh-jumpserver:v2.5.0
```

### 在 Kubernetes 中使用

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: easytier-ssh
spec:
  containers:
  - name: easytier-ssh
    image: ghcr.io/wuhins/easytier-ssh-jumpserver:latest
```

### 认证拉取（私有包）

```bash
# 登录 GHCR
echo $GITHUB_TOKEN | docker login ghcr.io -u $GITHUB_USERNAME --password-stdin

# 拉取镜像
docker pull ghcr.io/wuhins/easytier-ssh-jumpserver:latest
```

---

## 🔗 相关链接

- **GHCR 镜像**: https://github.com/WUHINS/easytier-ssh-jumpserver/pkgs/container/easytier-ssh-jumpserver
- **GitHub Actions**: https://github.com/WUHINS/easytier-ssh-jumpserver/actions
- **GITHUB_TOKEN 文档**: https://docs.github.com/en/actions/security-guides/automatic-token-authentication
- **GHCR 文档**: https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry

---

## ✅ 配置状态

- [x] 工作流已优化为只使用 GHCR
- [x] 使用 GITHUB_TOKEN 自动认证
- [x] 无需配置 Docker Hub Secrets
- [x] 文档已更新
- [x] 代码已推送到 GitHub

---

**配置完成时间**: 2024  
**镜像地址**: `ghcr.io/wuhins/easytier-ssh-jumpserver`  
**认证方式**: GITHUB_TOKEN 自动认证
