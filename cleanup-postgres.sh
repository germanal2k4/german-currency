#!/bin/bash
# Скрипт для удаления PostgreSQL из Kubernetes

echo "Удаление PostgreSQL из Kubernetes..."

kubectl delete deployment muffin-postgres -n muffin-services 2>/dev/null && echo "✓ Deployment удален" || echo "✗ Deployment не найден"
kubectl delete svc muffin-postgres -n muffin-services 2>/dev/null && echo "✓ Service удален" || echo "✗ Service не найден"
kubectl delete configmap postgres-init-script -n muffin-services 2>/dev/null && echo "✓ ConfigMap удален" || echo "✗ ConfigMap не найден"

echo ""
echo "PostgreSQL ресурсы удалены из Kubernetes."
echo "Теперь можно запустить PostgreSQL в Docker Compose:"
echo "  docker-compose up -d postgres"
