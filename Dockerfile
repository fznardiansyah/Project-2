# Menggunakan nginx resmi sebagai base image
FROM nginx:alpine

# Hapus default file nginx
RUN rm -rf /usr/share/nginx/html/*

# Salin semua file website ke dalam folder nginx html
COPY . /usr/share/nginx/html

# Port default nginx adalah 80
EXPOSE 80
