📦 Project Deployment & CI/CD — fznardiansyah/Project-2

Dokumen ini menjelaskan langkah-langkah dari awal hingga akhir untuk melakukan deployment dan implementasi CI/CD dari website statis berbasis HTML, CSS, JS menggunakan Docker, GitHub Actions, dan VPS (misalnya AWS Academy Lab).

📁 Struktur Project
```
PROJECT-2/
├── .github/workflows/        # Untuk CI/CD automation
│    ├── ci-docker-build.yml
│    └── cd-deploy.yml
├── assets/                   # Folder asset web
├── forms/
├── .dockerignore
├── Dockerfile                # Docker untuk static web
├── index.html
├── portfolio-details.html
├── service-details.html
├── starter-page.html
├── README.md
└── Readme.txt
```

✅ Topologi CI/CD Deployment untuk Static Website (PROJECT-2)
```
 ┌──────────────────┐
 │  Local Machine   │
 │ (VS Code + Git)  │
 └──────────────────┘
          │
          │ git push (feature/main)
          ▼
 ┌──────────────────────────┐
 │       GitHub Repo        │
 │ (.github/workflows/...)  │
 └──────────────────────────┘
          │
          │ Trigger Pull Request / Push ke Main
          ▼
 ┌──────────────────────────┐
 │    GitHub Actions CI     │
 │ - Build Docker Image     │
 │ - Push to Docker Hub     │
 └──────────────────────────┘
          │
          │
          ▼
 ┌──────────────────────┐
 │     Docker Hub       │
 │ (docker.io/username/ │
 │     project-2)       │
 └──────────────────────┘
          │
          │
          ▼
 ┌───────────────────────────┐
 │  GitHub Actions CD        │
 │ - SSH ke VPS              │
 │ - docker pull             │
 │ - docker run / compose up │
 └───────────────────────────┘
          │
          ▼
 ┌──────────────────────┐
 │     VPS / AWS EC2    │
 │    (nginx Docker)    │
 │ Exposed Port: 80     │
 └──────────────────────┘
          │
          ▼
 ┌───────────────────────┐
 │   Internet / Users    │
 │ Access via: http://   │
 │     IP-VPS.com        │
 └───────────────────────┘
```

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
   ```
   `Akses: http://localhost:8080`
   
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
| `VPS_HOST`        | IP VPS                                       |
| `VPS_USER`        | Username SSH VPS (`ubuntu`, `ec2-user`, dll) |
| `VPS_PRIVATE_KEY` | Isi dari private key (`.pem` / `id_rsa`)     |

🗂 Struktur Proyek dalam VPS (setelah deploy)
```
[Docker Container: project-2]
 └── /usr/share/nginx/html/
      ├── index.html
      ├── portfolio-details.html
      ├── service-details.html
      ├── starter-page.html
      └── assets/
```

✅ Pengujian CI/CD
1. Buat branch:
   `git checkout -b feature/ubah-footer`
2. Ubah salah satu HTML lalu commit dan push
3. Buat Pull Request → Merge ke main
4. GitHub Action akan otomatis build dan deploy
5. Buka VPS dan lihat hasil update di browser
   `http://IP-VPS`

📦 Alur CI/CD Detail
| Proses           | Keterangan                                             |
| ---------------- | ------------------------------------------------------ |
| **Dev & Commit** | Kamu coding di VS Code → git push ke GitHub            |
| **CI (Build)**   | GitHub Actions build Docker Image → push ke Docker Hub |
| **CD (Deploy)**  | GitHub Actions SSH ke VPS → pull image → docker run    |
| **Akses Web**    | User/public akses website via domain atau IP VPS       |

