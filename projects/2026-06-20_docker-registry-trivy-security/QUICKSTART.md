# ⚡ Quickstart - 10 minutes

## 1️⃣ Setup (3 min)

```bash
cd projects/2026-06-20_docker-registry-trivy-security

# Make scripts executable
chmod +x scripts/*.sh

# Start all services
docker-compose up -d

# Wait for Harbor
sleep 30
```

✅ **Check status:**
```bash
docker-compose ps
```

## 2️⃣ Create a Project in Harbor (2 min)

```bash
./scripts/create-project.sh demo

# Expected output:
# ✅ Project created successfully!
```

Open http://localhost:8080 → login `admin` / `Harbor12345` → see "demo" project

## 3️⃣ Build a Secure Image (2 min)

```bash
cd images/nodejs

docker build -t localhost:5000/demo/app:v1 .

# Expected: Image built successfully
```

## 4️⃣ Scan with Trivy (2 min)

```bash
cd ../..

./scripts/scan-image.sh localhost:5000/demo/app:v1

# Expected: Shows vulnerabilities (if any)
```

## 5️⃣ Push to Harbor (1 min)

```bash
# Login
docker login localhost:5000 -u admin -p Harbor12345

# Push
docker push localhost:5000/demo/app:v1

# Expected: Image uploaded to registry
```

✅ **Verify in Harbor UI:**
- Open http://localhost:8080
- Projects → demo → Repositories
- See "app" with scan results

---

## 🔍 Try Scanning a Vulnerable Image

```bash
cd images/nodejs

# Build vulnerable version
docker build -f Dockerfile.bad -t test:vuln .

# Scan it
../../scripts/scan-image.sh test:vuln

# Expected: Shows CRITICAL vulnerabilities
```

---

## 🧹 Cleanup

```bash
./scripts/cleanup.sh
```

---

## 📚 What you learned

✅ Harbor: Private Docker registry  
✅ Trivy: Container vulnerability scanner  
✅ Registre API  
✅ Image security best practices  

---

## 📍 Key endpoints

| Service | URL | Creds |
|---------|-----|-------|
| Harbor UI | http://localhost:8080 | admin / Harbor12345 |
| Registry API | http://localhost:5000 | (same) |
| Trivy API | http://localhost:8081 | - |
| PostgreSQL | localhost:5432 | postgres / Harbor12345 |
| Redis | localhost:6379 | - |

---

**Next:** Check [README.md](README.md) for full documentation
