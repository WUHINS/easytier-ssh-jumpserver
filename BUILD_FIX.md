# 构建错误修复说明

## 🐛 遇到的错误

### 错误 1: scripts 目录未找到
```
ERROR: failed to build: failed to solve: failed to compute cache key: 
failed to calculate checksum of ref: "/scripts": not found
```

**原因**: GitHub Actions 中构建时，`scripts/` 目录没有被复制到 build 目录

**修复**:
```yaml
- name: Download EasyTier binaries
  run: |
    mkdir -p build
    
    # 复制 Dockerfile 和 scripts 到 build 目录
    cp Dockerfile build/
    cp -r scripts/ build/scripts/
    
    cd build
    # ... 下载 EasyTier 二进制
```

### 错误 2: 架构目录不匹配
```
ERROR: buildx failed with: ERROR: failed to solve: 
process "/bin/sh -c ARTIFACT_ARCH=""; if [ "$TARGETPLATFORM" = "linux/amd64" ]; then..." 
did not complete successfully: exit code: 1
```

**原因**: 
- 工作流下载的目录名：`easytier-linux-x86_64/`
- Dockerfile 期望的目录名：`x86_64/` (根据 TARGETPLATFORM)

**修复**: 修改工作流，使目录结构匹配 TARGETPLATFORM

```yaml
ARCHIVE_MAP=(
  "x86_64:easytier-linux-x86_64"
  "aarch64:easytier-linux-aarch64"
  "armv7hf:easytier-linux-armv7hf"
  "armhf:easytier-linux-armhf"
  "riscv64:easytier-linux-riscv64"
)

for mapping in "${ARCHIVE_MAP[@]}"; do
  ARCH_DIR="${mapping%%:*}"        # x86_64
  ARCHIVE_NAME="${mapping##*:}"    # easytier-linux-x86_64
  # 下载并解压到正确的目录
done
```

---

## ✅ 修复后的目录结构

### build/ 目录结构
```
build/
├── Dockerfile
├── scripts/
│   ├── entrypoint.sh
│   └── init-ssh.sh
├── x86_64/              # ← 匹配 TARGETPLATFORM=linux/amd64
│   └── easytier-core
├── aarch64/             # ← 匹配 TARGETPLATFORM=linux/arm64
│   └── easytier-core
├── armv7hf/             # ← 匹配 TARGETPLATFORM=linux/arm/v7
│   └── easytier-core
├── armhf/               # ← 匹配 TARGETPLATFORM=linux/arm/v6
│   └── easytier-core
└── riscv64/             # ← 匹配 TARGETPLATFORM=linux/riscv64
    └── easytier-core
```

---

## 🔧 Dockerfile 中的映射

```dockerfile
ARG TARGETPLATFORM

RUN ARTIFACT_ARCH=""; \
    if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
        ARTIFACT_ARCH="x86_64"; \
    elif [ "$TARGETPLATFORM" = "linux/arm/v6" ]; then \
        ARTIFACT_ARCH="armhf"; \
    elif [ "$TARGETPLATFORM" = "linux/arm/v7" ]; then \
        ARTIFACT_ARCH="armv7hf"; \
    elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
        ARTIFACT_ARCH="aarch64"; \
    elif [ "$TARGETPLATFORM" = "linux/riscv64" ]; then \
        ARTIFACT_ARCH="riscv64"; \
    fi; \
    cp /tmp/artifacts/${ARTIFACT_ARCH}/* /tmp/output;
```

---

## 📋 完整的修复内容

### 1. 复制必要文件
```yaml
# 复制 Dockerfile 和 scripts 到 build 目录
cp Dockerfile build/
cp -r scripts/ build/scripts/
```

### 2. 创建正确的目录结构
```yaml
ARCHIVE_MAP=(
  "x86_64:easytier-linux-x86_64"
  "aarch64:easytier-linux-aarch64"
  "armv7hf:easytier-linux-armv7hf"
  "armhf:easytier-linux-armhf"
  "riscv64:easytier-linux-riscv64"
)

for mapping in "${ARCHIVE_MAP[@]}"; do
  ARCH_DIR="${mapping%%:*}"        # 提取目录名 (x86_64)
  ARCHIVE_NAME="${mapping##*:}"    # 提取归档名 (easytier-linux-x86_64)
  
  mkdir -p "$ARCH_DIR"
  if curl -L -o "${ARCHIVE_NAME}.zip" "$URL" && unzip -o "${ARCHIVE_NAME}.zip"; then
    mv easytier-core* "$ARCH_DIR/"
    echo "Extracted to $ARCH_DIR/"
  fi
done
```

---

## 🎯 验证修复

### 本地测试
```bash
cd easytier-ssh-jumpserver

# 运行 build.sh
./build.sh build

# 检查目录结构
ls -la build/
# 应该看到：x86_64/, aarch64/, scripts/, Dockerfile
```

### GitHub Actions 验证
1. 访问：https://github.com/WUHINS/easytier-ssh-jumpserver/actions
2. 查看最新的构建日志
3. 确认 "Download EasyTier binaries" 步骤输出正确的目录结构

---

## 📊 修复前后对比

| 项目 | 修复前 | 修复后 |
|------|--------|--------|
| scripts 目录 | ❌ 未复制 | ✅ 已复制 |
| 架构目录名 | ❌ easytier-linux-x86_64 | ✅ x86_64 |
| TARGETPLATFORM 匹配 | ❌ 不匹配 | ✅ 完全匹配 |
| Dockerfile 复制 | ❌ 未复制 | ✅ 已复制 |

---

## ✅ 修复状态

- [x] scripts 目录已复制到 build/
- [x] Dockerfile 已复制到 build/
- [x] 架构目录名匹配 TARGETPLATFORM
- [x] 工作流已更新
- [x] 代码已推送到 GitHub

---

## 🔗 相关文件

- [工作流文件](./.github/workflows/build.yml)
- [Dockerfile](./Dockerfile)
- [构建脚本](./build.sh)

---

**修复完成时间**: 2024  
**状态**: ✅ 已修复并推送
