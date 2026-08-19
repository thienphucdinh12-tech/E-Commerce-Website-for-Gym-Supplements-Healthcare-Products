# ============================================================
# Dockerfile for ISP302_WEB (NutriOverflow Web & Admin)
# ============================================================

# Stage 1: Runtime Image using Tomcat 9 + JDK 8
FROM tomcat:9.0-jdk8-openjdk-slim

LABEL maintainer="Thien Phuc <thienphucdinh12@gmail.com>"
LABEL description="Docker image for NutriOverflow Web & Admin applications"

# Clean default webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy pre-compiled WAR packages to Tomcat webapps folder
COPY Nutri_Overflow_Website/dist/NutriOverflow_Website.war /usr/local/tomcat/webapps/NutriOverflow_Website.war
COPY Nutri_Overflow_Admin/dist/NutriOverflow_Admin.war /usr/local/tomcat/webapps/NutriOverflow_Admin.war

# Expose Tomcat default port
EXPOSE 8080

# Start Tomcat Server
CMD ["catalina.sh", "run"]
