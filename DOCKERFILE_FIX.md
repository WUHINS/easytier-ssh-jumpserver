# Dockerfile 架构路径修复

## 🐛 问题描述

构建失败，错误信息：
```
ERROR: process "/bin/sh -c ARTIFACT_ARCH=""; if [ "$TARGETPLATFORM" = "linux/amd64" ]; then...
cp /tmp/artifacts/easytier-linux-${ARTIFACT_ARCH}/* /tmp/output;" 
did not complete successfully: exit code: 1
```

## 🔍 根本原因

1. **工作流中创建的目录结构**:
   ```
   build/
   ├── x86_64/
   │   └── easytier-core
   ├── aarch64/
   └── ...
   ```

2. **Dockerfile 中的问题**:
   - `COPY . /tmp/artifacts` 复制 build 目录内容到 `/tmp/artifacts`
   - 但代码尝试访问 `/tmp/artifacts/easytier-linux-x86_64/` (错误路径)
   - 实际应该是 `/tmp/artifacts/x86_64/` (正确路径)

## ✅ 修复方案

### 修复 1: 更正路径映射

**修改前**:
```dockerfile
COPY . /tmp/artifacts
RUN cp /tmp/artifacts/easytier-linux-${ARTIFACT_ARCH}/* /tmp/output
```

**修改后**:
```dockerfile
COPY . /tmp/artifacts
RUN ARTIFACT_ARCH="..."; \
    if [ -d "/tmp/artifacts/$ARTIFACT_ARCH" ]; then \
        cp /tmp/artifacts/${ARTIFACT_ARCH}/* /tmp/output/; \
    else \
        echo "Directory not found!"; \
        ls -la /tmp/artifacts/; \
        exit 1; \
    fi
```

### 修复 2: 添加调试输出

为了在构建失败时更容易排查，添加了详细的调试信息：

```dockerfile
RUN ARTIFACT_ARCH="..."; \
    echo "Copying files from /tmp/artifacts/$ARTIFACT_ARCH/"; \
    ls -la /tmp/artifacts/ || echo "artifacts dir not found"; \
    if [ -d "/tmp/artifacts/$ARTIFACT_ARCH" ]; then \
        cp /tmp/artifacts/${ARTIFACT_ARCH}/* /tmp/output/; \
    else \
        echo "Directory /tmp/artifacts/${ARTIFACT_ARCH} not found!"; \
        ls -la /tmp/artifacts/; \
        exit 1; \
    fi
```

## 📋 完整的映射关系

| TARGETPLATFORM | ARTIFACT_ARCH | 目录路径 |
|----------------|---------------|----------|
| `linux/amd64` | `x86_64` | `/tmp/artifacts/x86_64/` |
| `linux/arm64` | `aarch64` | `/tmp/artifacts/aarch64/` |
| `linux/arm/v7` | `armv7hf` | `/tmp/artifacts/armv7hf/` |
| `linux/arm/v6` | `armhf` | `/tmp/artifacts/armhf/` |
| `linux/riscv64` | `riscv64` | `/tmp/artifacts/riscv64/` |

## 🔧 工作流配合

GitHub Actions 工作流中创建的目录结构：

```yaml
ARCHIVE_MAP=(
  "x86_64:easytier-linux-x86_64"
  "aarch64:easytier-linux-aarch64"
  "armv7hf:easytier-linux-armv7hf"
  "armhf:easytier-linux-armhf"
  "riscv64:easytier-linux-riscv64"
)

for mapping in "${ARCHIVE_MAP[@]}"; do
  ARCH_DIR="${mapping%%:*}"  # x86_64
  # 下载并解压到 $ARCH_DIR/
done
```

## 📊 修复验证

### 本地验证
```bash
cd easytier-ssh-jumpserver

# 模拟工作流创建目录结构
mkdir -p build
cd build
mkdir -p x86_64 aarch64 armv7hf armhf riscv64
touch x86_64/easytier-core

# 查看结构
ls -la
# 应该看到：x86_64/, aarch64/, 等目录
```

### GitHub Actions 验证
查看构建日志中的调试输出：
```
Copying files from /tmp/artifacts/x86_64/
total 5
drwxr-xr-x 1 root root 4096 Mar 20 10:00 .
drwxr-xr-x 1 root root 4096 Mar 20 10:00 ..
drwxr-xr-x 2 root root 4096 Mar 20 10:00 x86_64
drwxr-xr-x 2 root root 4096 Mar 20 10:00 aarch64
...
```

## ✅ 修复状态

- [x] Dockerfile 路径已修复
- [x] 添加了调试输出
- [x] 添加了目录存在性检查
- [x] 工作流目录结构正确
- [x] 代码已推送到 GitHub

## 🔗 相关文件

- [Dockerfile](./Dockerfile)
- [工作流文件](./.github/workflows/build.yml)
- [构建修复说明](./BUILD_FIX.md)

---

**修复完成时间**: 2024  
**状态**: ✅ 已修复并推送
