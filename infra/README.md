# Infra — Minikube K8s 로컬 환경

Minikube 기반 로컬 Kubernetes 클러스터에서 Docker Private Registry, 백엔드, 프론트엔드를 배포합니다.

## K8s 매니페스트 구조

```
k8s/
├── registry-deployment.yaml   # Docker Private Registry Deployment
├── registry-service.yaml      # Docker Private Registry Service (NodePort)
├── backend-deployment.yaml    # 백엔드 Deployment
├── backend-service.yaml       # 백엔드 Service (NodePort)
├── frontend-deployment.yaml   # 프론트엔드 Deployment
├── frontend-service.yaml      # 프론트엔드 Service (NodePort)
└── monitoring/                # 모니터링 관련 설정
```

## 요구 사항

| 항목 | 최소 사양 |
|------|----------|
| CPU | 2코어 |
| 메모리 | 4GB |
| Docker | 설치 및 실행 중 |

## 클러스터 시작

```bash
minikube start --cpus=2 --memory=4096 --driver=docker
kubectl cluster-info
```

## 매니페스트 배포

```bash
kubectl apply -f k8s/
kubectl get pods       # 모든 Pod STATUS=Running 확인
kubectl get services
```

## 로컬 접근 (port-forward)

각 명령은 별도 터미널에서 실행:

```bash
kubectl port-forward svc/registry-service 5000:5000   # Registry
kubectl port-forward svc/backend-service 8080:8080     # Backend
kubectl port-forward svc/frontend-service 3000:3000    # Frontend
```

## 이미지 빌드 & Push

### 사전 준비: insecure registry 설정

Docker Desktop → Settings → Docker Engine의 `daemon.json`에 추가 후 재시작:

```json
{
  "insecure-registries": ["localhost:5000"]
}
```

### 스크립트로 빌드/푸시

```bash
bash scripts/build-and-push.sh frontend frontend latest
bash scripts/build-and-push.sh backend backend latest
```

### 수동 빌드/푸시

Registry port-forward 실행 상태에서:

```bash
# 백엔드
docker build -t localhost:5000/backend:latest ./backend
docker push localhost:5000/backend:latest

# 프론트엔드
docker build -t localhost:5000/frontend:latest ./frontend
docker push localhost:5000/frontend:latest

# 배포 반영
kubectl rollout restart deployment backend frontend
```

## 트러블슈팅

```bash
kubectl get pods
kubectl logs <pod-name>
kubectl logs -f <pod-name>       # 실시간 로그
kubectl describe pod <pod-name>  # 상세 상태 확인
```
