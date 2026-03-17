# 구현 계획: Minikube K8s 로컬 개발 환경 구성

## 개요

Minikube 기반 로컬 Kubernetes 클러스터에서 Docker Private Registry, 백엔드, 프론트엔드를 배포하기 위한 매니페스트 파일과 README 가이드를 단계적으로 작성한다. Registry를 먼저 구성한 뒤, 백엔드/프론트엔드 순서로 진행하며, 마지막에 README 문서로 전체 가이드를 완성한다.

## Tasks

- [x] 1. k8s 디렉토리 생성 및 Registry 매니페스트 작성
  - [x] 1.1 Registry Deployment 매니페스트 작성
    - `k8s/registry-deployment.yaml` 파일 생성
    - `registry:2` 이미지, 컨테이너 포트 5000, replicas 1 설정
    - `app: registry` 라벨 지정
    - emptyDir 볼륨을 `/var/lib/registry` 경로에 마운트
    - 리소스 요청(CPU 100m, 메모리 128Mi) 및 제한(CPU 500m, 메모리 512Mi) 설정
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6, 8.7_
  - [x] 1.2 Registry Service 매니페스트 작성
    - `k8s/registry-service.yaml` 파일 생성
    - Service 타입 NodePort, `app: registry` 셀렉터, targetPort 5000 설정
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_

- [x] 2. 백엔드 매니페스트 작성
  - [x] 2.1 Backend Deployment 매니페스트 작성
    - `k8s/backend-deployment.yaml` 파일 생성
    - 이미지 `localhost:5000/backend:latest`, 컨테이너 포트 8080, replicas 1 설정
    - `app: backend` 라벨 지정
    - 리소스 요청(CPU 100m, 메모리 128Mi) 및 제한(CPU 500m, 메모리 256Mi) 설정
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 10.3_

  - [x] 2.2 Backend Service 매니페스트 작성
    - `k8s/backend-service.yaml` 파일 생성
    - Service 타입 NodePort, `app: backend` 셀렉터, targetPort 8080 설정
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [x] 3. 프론트엔드 매니페스트 작성
  - [x] 3.1 Frontend Deployment 매니페스트 작성
    - `k8s/frontend-deployment.yaml` 파일 생성
    - 이미지 `localhost:5000/frontend:latest`, 컨테이너 포트 3000, replicas 1 설정
    - `app: frontend` 라벨 지정
    - 리소스 요청(CPU 100m, 메모리 128Mi) 및 제한(CPU 500m, 메모리 256Mi) 설정
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 10.4_

  - [x] 3.2 Frontend Service 매니페스트 작성
    - `k8s/frontend-service.yaml` 파일 생성
    - Service 타입 NodePort, `app: frontend` 셀렉터, targetPort 3000 설정
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [-] 4. Checkpoint - 매니페스트 파일 검증
  - 모든 YAML 파일이 유효한 Kubernetes 문법을 준수하는지 확인
  - `kubectl apply -f k8s/` 명령으로 전체 리소스를 한 번에 배포할 수 있는 구조인지 확인
  - Ensure all tests pass, ask the user if questions arise.
  - _Requirements: 6.1, 6.2, 6.3, 6.4_

- [ ] 5. README.md 배포 가이드 작성
  - [~] 5.1 Minikube 클러스터 구성 가이드 섹션 작성
    - Minikube 클러스터 시작 명령어 포함
    - 최소 요구 사양(CPU, 메모리) 명시
    - `kubectl cluster-info` 명령으로 클러스터 상태 확인 방법 안내
    - _Requirements: 1.1, 1.2, 1.3_

  - [~] 5.2 매니페스트 배포 및 검증 가이드 섹션 작성
    - `kubectl apply -f k8s/` 매니페스트 적용 명령어 포함
    - `kubectl get pods` Pod 상태 확인 명령어 포함
    - `kubectl get services` Service 상태 확인 명령어 포함
    - `kubectl port-forward` 사용 예시 (Registry 5000, Backend 8080, Frontend 3000) 포함
    - `kubectl logs` 로그 확인 명령어 안내
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

  - [~] 5.3 로컬 이미지 빌드 및 Registry push/pull 가이드 섹션 작성
    - Docker 이미지 빌드 및 Private Registry push 절차 안내
    - `localhost:5000/이미지명:태그` 형식의 이미지 태깅 방법 안내
    - `docker push`, `docker pull` 명령 예시 포함
    - insecure registry 설정 방법 안내
    - _Requirements: 10.1, 10.2, 10.5, 10.6_

- [~] 6. Final Checkpoint - 전체 검증
  - 모든 매니페스트 파일과 README 문서가 요구사항을 충족하는지 최종 확인
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- 이 프로젝트는 YAML 매니페스트와 Markdown 문서로 구성되므로 별도의 프로그래밍 언어가 필요하지 않습니다
- Registry를 먼저 배포한 뒤 백엔드/프론트엔드 이미지를 push하는 순서를 따릅니다
- 체크포인트에서 YAML 유효성과 전체 구조를 검증합니다
- 각 태스크는 특정 요구사항을 참조하여 추적 가능합니다
