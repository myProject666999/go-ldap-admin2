# 基于 Windows 的 Go-LDAP-Admin 多阶段构建 Dockerfile
# 此 Dockerfile 用于构建后端和前端，并运行在 Windows 容器中

# ==================== 阶段1: 构建后端 ====================
FROM golang:1.23-windowsservercore-ltsc2022 AS backend-builder

WORKDIR /build

# 复制 go.mod 和 go.sum 先下载依赖（利用缓存）
COPY go-ldap-admin/go.mod go-ldap-admin/go.sum ./
RUN go mod download

# 复制后端源代码
COPY go-ldap-admin/ .

# 构建 Windows 可执行文件
RUN go build -o go-ldap-admin.exe main.go

# ==================== 阶段2: 构建前端 ====================
FROM mcr.microsoft.com/windows/servercore:ltsc2022 AS frontend-builder

# 安装 Node.js
ADD https://nodejs.org/dist/v18.20.4/node-v18.20.4-x64.msi C:\node.msi
RUN msiexec /i C:\node.msi /qn

WORKDIR /build

# 复制前端源代码
COPY go-ldap-admin-ui/ .

# 安装依赖并构建
RUN npm install && npm run build:prod

# ==================== 阶段3: 最终运行镜像 ====================
FROM mcr.microsoft.com/windows/servercore:ltsc2022

WORKDIR /app

# 设置环境变量
ENV TZ=Asia/Shanghai
ENV BINARY_NAME=go-ldap-admin
ENV PORT=8888

# 复制后端可执行文件
COPY --from=backend-builder /build/go-ldap-admin.exe .

# 复制配置文件
COPY go-ldap-admin/config.yml .
COPY go-ldap-admin/LICENSE .

# 复制前端构建产物
RUN mkdir public\static\dist
COPY --from=frontend-builder /build/dist ./public/static/dist

# 创建数据目录
RUN mkdir data\logs

# 暴露端口
EXPOSE 8888

# 启动命令
CMD ["go-ldap-admin.exe"]
