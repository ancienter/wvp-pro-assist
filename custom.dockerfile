# syntax=docker/dockerfile:1.4
FROM maven:3.6.3-amazoncorretto-8 as builder
WORKDIR /build
COPY . /build
# RUN mvn clean package -X -D skipTests -s custom.settings.xml
# 需要启用Docker的BuildKit功能
RUN --mount=type=cache,id=m2_cache,sharing=locked,target=/root/.m2 mvn clean package -X -D skipTests -s custom.settings.xml
FROM amazoncorretto:8-alpine3.19
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && apk add --no-cache ffmpeg
WORKDIR /app
COPY --from=builder /build/target/*.jar ./app.jar
ENTRYPOINT ["java", "-jar", "app.jar", "-server", "-Djava.awt.headless=true", "-Djava.security.egd=file:/dev/./urandom", "-Dfile.encoding=UTF-8", "-Duser.timezone=Asia/Shanghai"]