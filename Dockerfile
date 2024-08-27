# 使用官方的 Tomcat 基础镜像
FROM tomcat:9.0

# 删除默认的 ROOT 应用
RUN rm -rf /usr/local/tomcat/webapps/ROOT

# 将你的 WAR 包复制到 Tomcat 的 webapps 目录中
COPY your-drawio.war /usr/local/tomcat/webapps/ROOT.war

# Expose the default port
EXPOSE 8080
