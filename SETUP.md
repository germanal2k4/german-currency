# Инструкция по развёртыванию проекта

## Требования

- Docker и Docker Compose
- Minikube
- kubectl
- Helm и Helmfile

---

## Шаг 1: Запуск локальных сервисов

```bash
docker compose up -d
```
поменяйте свой айпи по подсказке в файле prometheus values по подсказке команда

```bash
minikube ssh "getent hosts host.minikube.internal" | awk '{print $1}'
```

## Шаг 2: Запуск Minikube

```bash
minikube start
```

---

## Шаг 3: Создание bucket в MinIO для Thanos

```bash
docker exec muffin-minio mc alias set local http://localhost:9000 minio minio123
docker exec muffin-minio mc mb local/thanos --ignore-existing

docker exec muffin-minio mc ls local/
```

---

## Шаг 4: Развёртывание через Helmfile

```bash
helmfile sync
```

---

## Шаг 5: Настройка /etc/hosts

```bash
kubectl -n istio-system get svc istio-ingress

echo "ВАШ_АЙПИ wallet.example.com" | sudo tee -a /etc/hosts
```

---

## Шаг 6: Доступ к UI

```bash
nohup kubectl -n istio-system port-forward svc/prometheus-operated 9090:9090 --address 0.0.0.0 > /dev/null 2>&1 &
```

## Шаг 7: Доступ с локальной машины

На **локальной машине**:

```bash
ssh -L 9090:localhost:9090 \
    user@АЙПИ_ВАШЕЙ_ВИРТУАЛКИ(ЕСЛИ ВЫ С НЕЕ СМОТРИТЕ КОНЕЧНО)
```

Затем открыть в браузере:
- http://localhost:9090 — Prometheus

---

## Шаг 8: Генерация трафика

```bash
curl http://wallet.example.com/actuator/health

curl -X 'POST' \
  'http://wallet.example.com/v1/muffin-wallet/23ffa45c-997d-4638-8be5-2e183fcd47d2/transaction' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "to_muffin_wallet_id": "41b0ed8e-8ff0-46e9-afe6-51cab3012a87",
  "amount": 10
}'

for i in {1..100}; do
  curl -s http://wallet.example.com/actuator/health > /dev/null
done
```

---

## PromQL запросы для графиков

### 1. Количество запросов в секунду по каждому методу REST API

```promql
sum(rate(istio_requests_total{destination_service_namespace="muffin-services"}[5m])) by (request_path, request_method)
```

### 2. Количество ошибок в логах приложения

```promql
logback_events_total{level="error"}
```

### 3. 99-й персентиль времени ответа HTTP

```promql
histogram_quantile(0.99, sum(rate(istio_request_duration_milliseconds_bucket{destination_service_namespace="muffin-services"}[5m])) by (le, destination_service_name))
```

### 4. Количество активных соединений к PostgreSQL

```promql
sum(pg_stat_activity_count{datname="muffin_wallet"})
```

```promql
hikaricp_connections
```

---

## Проверка LTS я поставил ретеншн 2 часа чтобы они собрались пока я тестил можете уменьшить его в конфиге

```bash
kubectl -n istio-system logs prometheus-prometheus-kube-prometheus-prometheus-0 -c thanos-sidecar --tail=20

docker exec muffin-minio mc ls local/thanos/ --recursive

docker exec muffin-minio mc cat local/thanos/номербакета/meta.json | jq чтобы чекнуть есть ли логи или нет 

kubectl -n istio-system get pvc
```

