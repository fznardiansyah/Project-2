# Menggunakan nginx resmi sebagai base image
FROM nginx:alpine

# Salin semua file website ke dalam folder nginx html
COPY . /usr/share/nginx/html

# Port default nginx adalah 80
EXPOSE 80
