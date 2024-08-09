# Menggunakan image dasar PHP dengan Apache
FROM php:7.4-apache
# Menyiapkan direktori kerja
WORKDIR /var/www/html
# Menyalin semua file aplikasi ke direktori kerja
COPY . .
# Mengatur izin untuk direktori kerja
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html
# Memasang ekstensi PHP yang diperlukan (jika ada)
RUN docker-php-ext-install mysqli pdo pdo_mysql
# Mengekspos port 80 untuk mengakses aplikasi
EXPOSE 80
# Menjalankan Apache di latar depan
CMD ["apache2-foreground"]
