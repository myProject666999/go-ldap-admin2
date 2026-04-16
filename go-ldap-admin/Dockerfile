FROM node:18-alpine AS ui-builder

WORKDIR /app/ui

# 复制前端项目文件
COPY go-ldap-admin-ui/package.json go-ldap-admin-ui/package-lock.json* ./
RUN npm install

COPY go-ldap-admin-ui/ .
RUN npm run build:prod

FROM golang:1.25-alpine AS builder

WORKDIR /app

# 安装依赖
RUN apk add --no-cache git

# 复制go mod文件
COPY go.mod go.sum ./
RUN go mod download

# 复制源代码
COPY . .

# 从前端构建阶段复制构建好的文件
COPY --from=ui-builder /app/ui/dist ./public/static/dist

# 编译
RUN CGO_ENABLED=0 GOOS=linux go build -o go-ldap-admin .

FROM alpine:latest

WORKDIR /app
LABEL maintainer=eryajf@163.com

ENV TZ=Asia/Shanghai

# 安装必要的工具
RUN apk add --no-cache ca-certificates tzdata

COPY --from=builder /app/go-ldap-admin .
COPY config.yml .

EXPOSE 8888

CMD ["./go-ldap-admin"]
