FROM nginx:alpine
COPY _site/ /usr/share/nginx/html

#HTTP Basic Auth
RUN apk add --no-cache apache2-utils
RUN htpasswd -bc /etc/nginx/.htpasswd user password

#Nginx config to use .htpasswd
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
