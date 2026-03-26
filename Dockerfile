FROM nginx:alpine

# Create a non-privileged user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Remove default assets
RUN rm -rf /usr/share/nginx/html/*

# Copy files and ensure the new user has permissions
COPY . /usr/share/nginx/html/
RUN chown -R appuser:appgroup /usr/share/nginx/html

# Switch to the non-root user
USER appuser

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]