# Notion 검색 챗봇 & 임베딩 관리 시스템

Notion 페이지 콘텐츠를 자연어로 검색하는 챗봇과 임베딩 관리 백오피스를 제공하는 풀스택 프로젝트입니다.
Minikube 기반 로컬 K8s 환경에서 운영됩니다.

## 프로젝트 구조

```
├── frontend/             # React 프론트엔드
├── backend/              # Python 백엔드 (FastAPI)
├── k8s/                  # Kubernetes 매니페스트
├── scripts/              # 빌드/배포 스크립트
└── infra/                # 인프라(K8s) 문서
```

---

## Frontend

기술 스택: React 19 + TypeScript 5.9, Vite 8, Tailwind CSS, React Router v7

### 주요 기능

챗봇 (`/`):
- 자연어 질문으로 Notion 페이지 콘텐츠 검색
- 대화 세션 관리 (생성, 전환, 이력 조회)
- AI 응답에 Notion 출처 링크 표시
- 로딩 인디케이터 및 에러 처리 (재시도 지원)
- 새 메시지 자동 스크롤

백오피스 (`/admin`):
- Notion 페이지 목록 조회 및 임베딩 상태 관리
- 파일 업로드 (드래그앤드롭, PDF/DOCX/TXT/MD, 최대 10개·50MB)
- 임베딩 상태별 필터링 (대기, 진행 중, 완료, 실패)
- 개별/일괄 임베딩 생성 및 진행률 표시
- 페이지 제목 검색, 페이지네이션

디자인 시스템: "Quiet Confidence" 다크 테마 (`#0A0A0F` 배경, `#4A7CFF` 포인트 블루)

```bash
cd frontend
npm install && npm run dev    # 개발 서버
npm run build                 # 프로덕션 빌드
npm run test                  # 테스트 (Vitest + fast-check)
```

---

## Backend

기술 스택: Python, FastAPI

현재 헬스체크 및 기본 라우트를 제공하며, Notion 연동 API를 확장 예정입니다.

주요 API 엔드포인트:

| 메서드 | 경로 | 설명 |
|--------|------|------|
| GET | `/api/v1/health` | 헬스 체크 |
| GET | `/api/v1/notion/pages` | 문서 목록 |
| POST | `/api/v1/notion/workspace/sync` | 페이지 일괄 동기화 |
| GET | `/api/v1/documents` | 문서 조회 |
| POST | `/api/v1/pipeline/{id}/run` | 임베딩 파이프라인 실행 |
| POST | `/api/v1/pipeline/{id}/retry` | 파이프라인 재시도 |

```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload     # 개발 서버
```

---

## Infra (K8s)

Minikube 기반 로컬 Kubernetes 환경. 상세 내용은 [infra/README.md](infra/README.md) 참고.

구성 요소:
- Docker Private Registry (NodePort)
- Backend Deployment + Service
- Frontend Deployment + Service

빠른 시작:
```bash
minikube start --cpus=2 --memory=4096 --driver=docker
kubectl apply -f k8s/
```

이미지 빌드 & 배포:
```bash
bash scripts/build-and-push.sh frontend frontend latest
bash scripts/build-and-push.sh backend backend latest
```
