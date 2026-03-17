# 요구사항 문서

## 소개

로컬 개발 환경에서 Minikube를 사용하여 Kubernetes 클러스터를 구성하고, 백엔드와 프론트엔드 애플리케이션을 각각 독립된 Pod로 배포하기 위한 매니페스트 파일을 형상관리한다. 또한 Docker Private Registry를 클러스터 내에 배포하여 로컬에서 빌드한 Docker 이미지를 Registry에 push/pull 할 수 있도록 한다. Service 타입은 NodePort를 사용하며, 이후 `kubectl port-forward`를 통해 로컬에서 접근할 수 있도록 한다.

## 용어 정의

- **Minikube_Cluster**: 로컬 머신에서 실행되는 단일 노드 Kubernetes 클러스터
- **Backend_Deployment**: 백엔드 애플리케이션 Pod를 관리하는 Kubernetes Deployment 리소스
- **Frontend_Deployment**: 프론트엔드 애플리케이션 Pod를 관리하는 Kubernetes Deployment 리소스
- **Backend_Service**: 백엔드 Pod에 대한 네트워크 접근을 제공하는 Kubernetes Service 리소스
- **Frontend_Service**: 프론트엔드 Pod에 대한 네트워크 접근을 제공하는 Kubernetes Service 리소스
- **Manifest_File**: Kubernetes 리소스를 선언적으로 정의하는 YAML 형식의 파일
- **NodePort**: 클러스터 외부에서 고정 포트를 통해 서비스에 접근할 수 있게 하는 Service 타입
- **Registry_Deployment**: Docker Private Registry Pod를 관리하는 Kubernetes Deployment 리소스
- **Registry_Service**: Docker Private Registry Pod에 대한 네트워크 접근을 제공하는 Kubernetes Service 리소스
- **Docker_Registry**: Minikube 클러스터 내에서 Docker 이미지를 저장하고 배포하는 Private Container Registry (registry:2 이미지 기반)

## 요구사항

### 요구사항 1: Minikube 클러스터 구성 가이드

**사용자 스토리:** 개발자로서, 로컬 환경에서 Minikube 클러스터를 생성하고 싶다. 이를 통해 클라우드 없이도 Kubernetes 환경을 테스트할 수 있다.

#### 인수 조건

1. THE Manifest_File SHALL Minikube 클러스터 시작에 필요한 명령어를 README 문서에 포함한다
2. THE Manifest_File SHALL Minikube 클러스터의 최소 요구 사양(CPU, 메모리)을 README 문서에 명시한다
3. WHEN Minikube 클러스터가 정상 시작되면, THE Minikube_Cluster SHALL `kubectl cluster-info` 명령으로 클러스터 상태를 확인할 수 있는 상태가 된다

### 요구사항 2: 백엔드 Deployment 매니페스트

**사용자 스토리:** 개발자로서, 백엔드 애플리케이션을 Kubernetes Pod로 배포하기 위한 Deployment 매니페스트를 작성하고 싶다. 이를 통해 백엔드 Pod의 생성과 관리를 선언적으로 수행할 수 있다.

#### 인수 조건

1. THE Backend_Deployment SHALL `k8s/backend-deployment.yaml` 파일에 정의된다
2. THE Backend_Deployment SHALL apiVersion, kind, metadata, spec 필드를 포함한다
3. THE Backend_Deployment SHALL `app: backend` 라벨을 Pod 템플릿에 지정한다
4. THE Backend_Deployment SHALL 컨테이너 이미지, 컨테이너 포트, 리소스 요청/제한을 명시한다
5. THE Backend_Deployment SHALL replicas 수를 1로 설정한다

### 요구사항 3: 백엔드 Service 매니페스트

**사용자 스토리:** 개발자로서, 백엔드 Pod에 네트워크로 접근하기 위한 Service 매니페스트를 작성하고 싶다. 이를 통해 클러스터 외부에서 백엔드 애플리케이션에 접근할 수 있다.

#### 인수 조건

1. THE Backend_Service SHALL `k8s/backend-service.yaml` 파일에 정의된다
2. THE Backend_Service SHALL Service 타입을 NodePort로 설정한다
3. THE Backend_Service SHALL `app: backend` 라벨 셀렉터를 사용하여 Backend_Deployment의 Pod를 선택한다
4. THE Backend_Service SHALL targetPort를 Backend_Deployment의 컨테이너 포트와 일치시킨다
5. WHEN `kubectl port-forward` 명령이 실행되면, THE Backend_Service SHALL 로컬 머신에서 백엔드 Pod로의 트래픽 전달을 지원한다

### 요구사항 4: 프론트엔드 Deployment 매니페스트

**사용자 스토리:** 개발자로서, 프론트엔드 애플리케이션을 Kubernetes Pod로 배포하기 위한 Deployment 매니페스트를 작성하고 싶다. 이를 통해 프론트엔드 Pod의 생성과 관리를 선언적으로 수행할 수 있다.

#### 인수 조건

1. THE Frontend_Deployment SHALL `k8s/frontend-deployment.yaml` 파일에 정의된다
2. THE Frontend_Deployment SHALL apiVersion, kind, metadata, spec 필드를 포함한다
3. THE Frontend_Deployment SHALL `app: frontend` 라벨을 Pod 템플릿에 지정한다
4. THE Frontend_Deployment SHALL 컨테이너 이미지, 컨테이너 포트, 리소스 요청/제한을 명시한다
5. THE Frontend_Deployment SHALL replicas 수를 1로 설정한다

### 요구사항 5: 프론트엔드 Service 매니페스트

**사용자 스토리:** 개발자로서, 프론트엔드 Pod에 네트워크로 접근하기 위한 Service 매니페스트를 작성하고 싶다. 이를 통해 클러스터 외부에서 프론트엔드 애플리케이션에 접근할 수 있다.

#### 인수 조건

1. THE Frontend_Service SHALL `k8s/frontend-service.yaml` 파일에 정의된다
2. THE Frontend_Service SHALL Service 타입을 NodePort로 설정한다
3. THE Frontend_Service SHALL `app: frontend` 라벨 셀렉터를 사용하여 Frontend_Deployment의 Pod를 선택한다
4. THE Frontend_Service SHALL targetPort를 Frontend_Deployment의 컨테이너 포트와 일치시킨다
5. WHEN `kubectl port-forward` 명령이 실행되면, THE Frontend_Service SHALL 로컬 머신에서 프론트엔드 Pod로의 트래픽 전달을 지원한다

### 요구사항 6: 매니페스트 형상관리 구조

**사용자 스토리:** 개발자로서, 모든 Kubernetes 매니페스트 파일을 Git으로 형상관리하고 싶다. 이를 통해 인프라 변경 이력을 추적하고 팀원과 공유할 수 있다.

#### 인수 조건

1. THE Manifest_File SHALL `k8s/` 디렉토리 하위에 모든 매니페스트 파일을 배치한다
2. THE Manifest_File SHALL 각 리소스(Deployment, Service)를 개별 YAML 파일로 분리한다
3. THE Manifest_File SHALL 유효한 Kubernetes YAML 문법을 준수한다
4. THE Manifest_File SHALL `kubectl apply -f k8s/` 명령으로 전체 리소스를 한 번에 배포할 수 있도록 구성한다

### 요구사항 7: 배포 및 검증 가이드

**사용자 스토리:** 개발자로서, 매니페스트를 Minikube 클러스터에 배포하고 정상 동작을 검증하는 방법을 알고 싶다. 이를 통해 배포 과정에서 발생하는 문제를 빠르게 파악할 수 있다.

#### 인수 조건

1. THE Manifest_File SHALL 매니페스트 적용 명령어(`kubectl apply`)를 README 문서에 포함한다
2. THE Manifest_File SHALL Pod 상태 확인 명령어(`kubectl get pods`)를 README 문서에 포함한다
3. THE Manifest_File SHALL Service 상태 확인 명령어(`kubectl get services`)를 README 문서에 포함한다
4. THE Manifest_File SHALL `kubectl port-forward` 사용 예시를 README 문서에 포함한다
5. IF Pod가 정상 시작되지 않으면, THEN THE Manifest_File SHALL 로그 확인 명령어(`kubectl logs`)를 README 문서에 안내한다

### 요구사항 8: Docker Private Registry Deployment 매니페스트

**사용자 스토리:** 개발자로서, 로컬에서 빌드한 Docker 이미지를 저장하기 위한 Private Registry를 Minikube 클러스터 내에 배포하고 싶다. 이를 통해 별도의 외부 레지스트리 없이 클러스터 내에서 이미지를 관리할 수 있다.

#### 인수 조건

1. THE Registry_Deployment SHALL `k8s/registry-deployment.yaml` 파일에 정의된다
2. THE Registry_Deployment SHALL apiVersion, kind, metadata, spec 필드를 포함한다
3. THE Registry_Deployment SHALL `app: registry` 라벨을 Pod 템플릿에 지정한다
4. THE Registry_Deployment SHALL `registry:2` 공식 컨테이너 이미지를 사용한다
5. THE Registry_Deployment SHALL 컨테이너 포트(5000), 리소스 요청/제한을 명시한다
6. THE Registry_Deployment SHALL replicas 수를 1로 설정한다
7. THE Registry_Deployment SHALL 이미지 저장을 위한 emptyDir 또는 PersistentVolumeClaim 볼륨을 `/var/lib/registry` 경로에 마운트한다

### 요구사항 9: Docker Private Registry Service 매니페스트

**사용자 스토리:** 개발자로서, Docker Private Registry Pod에 네트워크로 접근하기 위한 Service 매니페스트를 작성하고 싶다. 이를 통해 클러스터 내부 및 로컬 머신에서 Registry에 이미지를 push/pull 할 수 있다.

#### 인수 조건

1. THE Registry_Service SHALL `k8s/registry-service.yaml` 파일에 정의된다
2. THE Registry_Service SHALL Service 타입을 NodePort로 설정한다
3. THE Registry_Service SHALL `app: registry` 라벨 셀렉터를 사용하여 Registry_Deployment의 Pod를 선택한다
4. THE Registry_Service SHALL targetPort를 Registry_Deployment의 컨테이너 포트(5000)와 일치시킨다
5. WHEN `kubectl port-forward` 명령이 실행되면, THE Registry_Service SHALL 로컬 머신에서 Registry Pod로의 트래픽 전달을 지원한다

### 요구사항 10: 로컬 이미지 빌드 및 Private Registry push/pull 구성

**사용자 스토리:** 개발자로서, 로컬에서 빌드한 Docker 이미지를 클러스터 내 Private Registry에 push하고, Deployment에서 해당 이미지를 pull하여 사용하고 싶다. 이를 통해 로컬 빌드 이미지를 클러스터 내 Pod에서 바로 사용할 수 있다.

#### 인수 조건

1. THE Manifest_File SHALL 로컬에서 Docker 이미지를 빌드하고 Private Registry에 push하는 절차를 README 문서에 포함한다
2. THE Manifest_File SHALL `localhost:<NodePort>/이미지명:태그` 형식의 이미지 태깅 방법을 README 문서에 안내한다
3. THE Backend_Deployment SHALL Docker_Registry에서 이미지를 pull할 수 있도록 이미지 경로를 Registry 주소 기반으로 설정한다
4. THE Frontend_Deployment SHALL Docker_Registry에서 이미지를 pull할 수 있도록 이미지 경로를 Registry 주소 기반으로 설정한다
5. IF Docker_Registry에 접근할 수 없으면, THEN THE Manifest_File SHALL insecure registry 설정 방법을 README 문서에 안내한다
6. THE Manifest_File SHALL `docker push`, `docker pull` 명령 예시를 README 문서에 포함한다
