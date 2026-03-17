# Notion 검색 챗봇 — 인프라 & 프로젝트 개요

Notion 페이지를 자연어로 검색하는 챗봇 + 임베딩 관리 백오피스 시스템.
Minikube 기반 로컬 K8s 환경에서 Private Registry, 백엔드, 프론트엔드를 배포합니다.

## 프로젝트 구조

```
├── k8s/                  # K8s 매니페스트 (Registry, Backend, Frontend)
├── scripts/              # 빌드/배포 스크립트
├── backend/              # Python 백엔드 (FastAPI)
├── frontend/             # React 프론트엔드
└── infra/                # 인프라 문서
```

## 프론트엔드 요약

| 항목 | 내용 |
|------|------|
| 스택 | React 19, TypeScript 5.9, Vite 8, Tailwind CSS, React Router v7 |
| 테스트 | Vitest + React Testing Library + fast-check |
| 라우팅 | `/` 챗봇, `/admin` 백오피스 |

주요 기능:
- 챗봇: 자연어 Notion 검색, 세션 관리, 출처 링크, 자동 스크롤
- 백오피스: 페이지 목록/임베딩 상태 관리, 파일 업로드(PDF/DOCX/TXT/MD), 일괄 임베딩, 필터/검색/페이지네이션

```bash
cd frontend && npm install && npm run dev   # 개발 서버
npm run build                                # 프로덕션 빌드
npm run test                                 # 테스트
```

## K8s 로컬 환경 (Minikube)

### 요구 사항

- CPU 2코어, 메모리 4GB, Docker 실행 중

### 클러스터 시작

```bash
minikube start --cpus=2 --memory=4096 --driver=docker
kubectl cluster-info
```

### 배포

```bash
kubectl apply -f k8s/
kubectl get pods          # 모든 Pod Running 확인
```

### 로컬 접근 (port-forward)

```bash
kubectl port-forward svc/registry-service 5000:5000
kubectl port-forward svc/backend-service 8080:8080
kubectl port-forward svc/frontend-service 3000:3000
```

### 이미지 빌드 & Push

사전 준비: Docker `daemon.json`에 `"insecure-registries": ["localhost:5000"]` 추가 후 재시작.

```bash
# Registry port-forward 실행 상태에서
docker build -t localhost:5000/backend:latest ./backend && docker push localhost:5000/backend:latest
docker build -t localhost:5000/frontend:latest ./frontend && docker push localhost:5000/frontend:latest

# 배포 반영
kubectl rollout restart deployment backend frontend
```

### 트러블슈팅

```bash
kubectl get pods
kubectl logs <pod-name>
kubectl logs -f <pod-name>
```

## API 엔드포인트 (주요)

| 메서드 | 경로 | 설명 |
|--------|------|------|
| GET | `/api/v1/health` | 헬스 체크 |
| GET | `/api/v1/notion/pages` | 문서 목록 |
| POST | `/api/v1/notion/workspace/sync` | 페이지 일괄 동기화 |
| GET | `/api/v1/documents` | 문서 조회 |
| POST | `/api/v1/pipeline/{id}/run` | 임베딩 실행 |
| POST | `/api/v1/pipeline/{id}/retry` | 파이프라인 재시도 |
