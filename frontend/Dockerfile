FROM nginx:alpine
WORKDIR /usr/share/nginx/html

# Copy static site
COPY index.html /usr/share/nginx/html/index.html

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
