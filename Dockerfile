FROM golang:1.25-alpine AS builder

WORKDIR /app

# 安装依赖
RUN apk add --no-cache git

# 复制go mod文件
COPY go-ldap-admin/go.mod go-ldap-admin/go.sum ./
RUN go mod download

# 复制源代码
COPY go-ldap-admin/ .

# 编译
RUN CGO_ENABLED=0 GOOS=linux go build -o go-ldap-admin .

FROM alpine:latest

WORKDIR /app
LABEL maintainer=eryajf@163.com

ENV TZ=Asia/Shanghai

# 安装必要的工具
RUN apk add --no-cache ca-certificates tzdata

COPY --from=builder /app/go-ldap-admin .
COPY --from=builder /app/config.yml .

EXPOSE 8888

CMD ["./go-ldap-admin"]
