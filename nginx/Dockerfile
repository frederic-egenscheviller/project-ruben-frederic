FROM nginx:1.25-alpine

# Copy the nginx configuration file
RUN rm /etc/nginx/conf.d/default.conf

COPY nginx.conf /etc/nginx/conf.d/
EXPOSE 8000

# Lunch the Nginx server
CMD ["nginx", "-g", "daemon off;"]