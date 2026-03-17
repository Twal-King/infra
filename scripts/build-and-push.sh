#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

IMAGE_NAME="${1:-backend}"
DOCKERFILE_DIR="${2:-$PROJECT_ROOT/backend}"
TAG="${3:-latest}"

# registry ClusterIP 사용 (minikube 내부에서 접근 가능)
CLUSTER_IP=$(kubectl get svc registry-service -o jsonpath='{.spec.clusterIP}')
REGISTRY="${CLUSTER_IP}:5000"

echo "[$(date)] Using registry at ${REGISTRY}"
echo "[$(date)] Building ${IMAGE_NAME}:${TAG} from ${DOCKERFILE_DIR}..."

# minikube docker daemon 사용하여 빌드
eval $(minikube docker-env)

docker build -t "${REGISTRY}/${IMAGE_NAME}:${TAG}" "${DOCKERFILE_DIR}"

echo "[$(date)] Pushing to ${REGISTRY}/${IMAGE_NAME}:${TAG}..."
docker push "${REGISTRY}/${IMAGE_NAME}:${TAG}"

# deployment 이미지를 ClusterIP 기반으로 업데이트
echo "[$(date)] Updating deployment/${IMAGE_NAME}..."
kubectl set image "deployment/${IMAGE_NAME}" "${IMAGE_NAME}=${REGISTRY}/${IMAGE_NAME}:${TAG}"
kubectl rollout restart "deployment/${IMAGE_NAME}"
kubectl rollout status "deployment/${IMAGE_NAME}"

echo "[$(date)] Done. ${IMAGE_NAME} is running."
