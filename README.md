# Minikube K8s 로컬 개발 환경

Minikube 기반 로컬 Kubernetes 클러스터에서 Docker Private Registry, 백엔드, 프론트엔드를 배포하기 위한 프로젝트입니다.

## 프로젝트 구조

```
├── k8s/
│   ├── registry-deployment.yaml   # Docker Private Registry Deployment
│   ├── registry-service.yaml      # Docker Private Registry Service (NodePort)
│   ├── backend-deployment.yaml    # 백엔드 Deployment
│   ├── backend-service.yaml       # 백엔드 Service (NodePort)
│   ├── frontend-deployment.yaml   # 프론트엔드 Deployment
│   └── frontend-service.yaml      # 프론트엔드 Service (NodePort)
├── backend/                       # 백엔드 애플리케이션 소스
├── frontend/                      # 프론트엔드 애플리케이션 소스
└── README.md
```

---

## Frontend 주요 기능

기술 스택: React 19 + TypeScript 5.9, Vite 8, Tailwind CSS, React Router v7, Vitest + fast-check

### 챗봇 (`/`)

- 자연어 질문으로 Notion 페이지 콘텐츠 검색
- 대화 세션 관리 (생성, 전환, 이력 조회)
- AI 응답에 Notion 출처 링크 표시
- 로딩 인디케이터 및 에러 처리 (재시도 지원)
- 새 메시지 자동 스크롤

### 백오피스 (`/admin`)

- Notion 페이지 목록 조회 및 임베딩 상태 관리
- 파일 업로드로 문서 임베딩 (드래그앤드롭, PDF/DOCX/TXT/MD, 최대 10개·50MB)
- 임베딩 상태별 필터링 (대기, 진행 중, 완료, 실패)
- 페이지 제목 텍스트 검색
- 개별/일괄 임베딩 생성 요청 및 진행률 표시
- 페이지네이션

### 디자인 시스템

"Quiet Confidence" 다크 테마 — `#0A0A0F` 배경, `#4A7CFF` 포인트 블루, 큰 border-radius, Inter 폰트 스택

---

## 1. Minikube 클러스터 구성

### 최소 요구 사양

| 항목 | 최소 사양 |
|------|----------|
| CPU | 2코어 |
| 메모리 | 4GB |
| Docker | 설치 및 실행 중 |

### 클러스터 시작

```bash
minikube start --cpus=2 --memory=4096 --driver=docker
```

### 클러스터 상태 확인

클러스터가 정상적으로 시작되었는지 확인합니다:

```bash
kubectl cluster-info
```

정상 출력 예시:
```
Kubernetes control plane is running at https://127.0.0.1:xxxxx
CoreDNS is running at https://127.0.0.1:xxxxx/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

---

## 2. 매니페스트 배포 및 검증

### 매니페스트 적용

`k8s/` 디렉토리의 모든 매니페스트를 한 번에 배포합니다:

```bash
kubectl apply -f k8s/
```

### Pod 상태 확인

```bash
kubectl get pods
```

모든 Pod의 STATUS가 `Running`인지 확인합니다:
```
NAME                        READY   STATUS    RESTARTS   AGE
registry-xxxxxxxxx-xxxxx    1/1     Running   0          1m
backend-xxxxxxxxx-xxxxx     1/1     Running   0          1m
frontend-xxxxxxxxx-xxxxx    1/1     Running   0          1m
```

### Service 상태 확인

```bash
kubectl get services
```

### 로컬 접근 (port-forward)

각 서비스에 로컬에서 접근하려면 `kubectl port-forward`를 사용합니다:

```bash
# Registry (localhost:5000)
kubectl port-forward svc/registry-service 5000:5000

# Backend (localhost:8080)
kubectl port-forward svc/backend-service 8080:8080

# Frontend (localhost:3000)
kubectl port-forward svc/frontend-service 3000:3000
```

> 각 명령은 별도의 터미널에서 실행하세요.

### 로그 확인

Pod가 정상적으로 시작되지 않는 경우 로그를 확인합니다:

```bash
# Pod 이름 확인
kubectl get pods

# 특정 Pod 로그 확인
kubectl logs <pod-name>

# 실시간 로그 확인
kubectl logs -f <pod-name>
```

---

## 3. 로컬 이미지 빌드 및 Registry Push/Pull

### 사전 준비: insecure registry 설정

Private Registry는 HTTPS가 아닌 HTTP로 동작하므로, Docker에 insecure registry 설정이 필요합니다.

Docker Desktop의 설정(Settings) → Docker Engine에서 `daemon.json`에 다음을 추가합니다:

```json
{
  "insecure-registries": ["localhost:5000"]
}
```

설정 후 Docker Desktop을 재시작합니다.

### 이미지 빌드 및 Push 절차

Registry가 실행 중인 상태에서 port-forward를 먼저 설정합니다:

```bash
kubectl port-forward svc/registry-service 5000:5000
```

#### 백엔드 이미지

```bash
# 1. 이미지 빌드
docker build -t backend:latest ./backend

# 2. Registry 주소로 태깅
docker tag backend:latest localhost:5000/backend:latest

# 3. Registry에 Push
docker push localhost:5000/backend:latest
```

#### 프론트엔드 이미지

```bash
# 1. 이미지 빌드
docker build -t frontend:latest ./frontend

# 2. Registry 주소로 태깅
docker tag frontend:latest localhost:5000/frontend:latest

# 3. Registry에 Push
docker push localhost:5000/frontend:latest
```

### 이미지 Pull

Registry에서 이미지를 가져오려면:

```bash
docker pull localhost:5000/backend:latest
docker pull localhost:5000/frontend:latest
```

### 이미지 태깅 형식

Private Registry에 push하기 위한 이미지 태그 형식:

```
localhost:5000/<이미지명>:<태그>
```

예시:
- `localhost:5000/backend:latest`
- `localhost:5000/frontend:latest`
- `localhost:5000/backend:v1.0.0`

### Deployment 이미지 업데이트

이미지를 Registry에 push한 후, Deployment를 재시작하여 최신 이미지를 반영합니다:

```bash
kubectl rollout restart deployment backend
kubectl rollout restart deployment frontend
```
