📦 Project Deployment & CI/CD — fznardiansyah/Project-2

Dokumen ini menjelaskan langkah-langkah dari awal hingga akhir untuk melakukan deployment dan implementasi CI/CD dari website statis berbasis HTML, CSS, JS menggunakan Docker, GitHub Actions, dan VPS (misalnya AWS Academy Lab).

📁 Struktur Project

project-2/
├── assets/
│   ├── css/
│   ├── img/
│   ├── js/
│   ├── scss/
│   └── vendor/
├── forms/
├── index.html
├── portfolio-details.html
├── service-details.html
├── starter-page.html

⚙️ Persiapan Awal
1. Sudah memiliki akun:
    - GitHub
    - Docker Hub
    - VPS (misalnya AWS Academy)
2. Sudah setup SSH key dan dapat akses VPS via terminal

🐳 Setup Docker Lokal
1. Clone Repository
   ```
   git clone git@github.com:fznardiansyah/Project-2.git
   cd Project-2
   ```
2. Buat Dockerfile
   ```
   FROM nginx:alpine
   COPY . /usr/share/nginx/html
   EXPOSE 80
   ```
3. Buat .dockerignore
   ```
   .git
   node_modules
   Dockerfile
   .dockerignore
   ```
4. Build & Run Docker Lokal
   ```
   docker build -t static-website .
   docker run -d -p 8080:80 portfolio-container
   (Akses: http://localhost:8080)
   ```
☁️ Push ke Docker Hub
```
docker tag portfolio-container fauzanardiansyah/portfolio:latest
docker push fauzanardiansyah/portfolio:latest
```
💻 Deploy Manual di VPS
```
ssh -i ~/.ssh/id_rsa ubuntu@<VPS_IP>
docker pull fauzanardiansyah/portfolio:latest
docker stop portfolio-container || true
docker rm portfolio-container || true
docker run -d --name static-container -p 80:80 fauzanardiansyah/portfolio:latest
```
🤖 CI/CD Automation (GitHub Actions)

1. CI - Build & Push Docker Image
   ```
   File: .github/workflows/ci-docker-build.yml
   name: Build and Push Docker Image
      
   on:
     push:
     branches:
     - main
      
    jobs:
     build:
       runs-on: ubuntu-latest
       steps:
         - name: Checkout Source Code
           uses: actions/checkout@v2
      
         - name: Login to Docker Hub
           uses: docker/login-action@v2
           with:
             username: ${{ secrets.DOCKER_USERNAME }}
             password: ${{ secrets.DOCKER_PASSWORD }}
      
         - name: Build and Push Docker Image
             uses: docker/build-push-action@v3
             with:
               context: .
               push: true
               tags: fauzanardiansyah/portfolio
    ```
2. CD - Deploy ke VPS Otomatis
   ```
   File: .github/workflows/cd-deploy.yml
   name: Deploy to VPS

   on:
     push:
     branches:
       - main
    
   jobs:
     deploy:
       runs-on: ubuntu-latest
       steps:
         - name: Deploy to VPS
           uses: appleboy/ssh-action@master
           with:
             host: ${{ secrets.VPS_HOST }}
             username: ${{ secrets.VPS_USER }}
             key: ${{ secrets.VPS_KEY }}
             script: |
               docker pull fauzanardiansyah/portfolio
               docker stop portfolio-container || true
               docker rm portfolio-container || true
               docker run -d --name portfolio-container -p 80:80 fauzanardiansyah/portfolio
    ```
🔐 Secrets GitHub Actions
| Secret Name       | Keterangan                                   |
| ----------------- | -------------------------------------------- |
| `DOCKER_USERNAME` | Username Docker Hub                          |
| `DOCKER_PASSWORD` | Password akun Docker (atau token)            |
| `VPS_HOST`        | IP VPS kamu                                  |
| `VPS_USER`        | Username SSH VPS (`ubuntu`, `ec2-user`, dll) |
| `VPS_PRIVATE_KEY` | Isi dari private key (`.pem` / `id_rsa`)     |

✅ Pengujian CI/CD
1. Buat branch:
   git checkout -b feature/ubah-footer
2. Ubah salah satu HTML lalu commit dan push
3. Buat Pull Request → Merge ke main
4. GitHub Action akan otomatis build dan deploy
5. Buka VPS dan lihat hasil update di browser
