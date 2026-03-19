# Use the lightweight Nginx Alpine image
FROM nginx:alpine

# Remove default nginx static assets
RUN rm -rf /usr/share/nginx/html/*

# Copy your static files to the nginx html directory
# This includes your index.html, style.css, script.js, and the assets folder
COPY . /usr/share/nginx/html/

# Expose port 80 to the cluster
EXPOSE 80

# Start Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]