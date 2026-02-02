# Отчёт: Развёртывание muffin-wallet и muffin-currency в Kubernetes (Minikube), сбор логов и трейсов

## 1. Состав решения

- **Приложения:** muffin-wallet, muffin-currency в namespace `muffin-services`.
- **Сбор логов:** Loki + Promtail. Логи подов собираются в Loki.
- **Трейсы:** Jaeger. muffin-currency и muffin-wallet отправляют трейсы в Jaeger .
- **Метрики:** Prometheus + при необходимости Thanos.
- **Визуализация:** Grafana с источниками Loki и Jaeger. Дашборды для логов и трейсов.
- **Операторы:** Prometheus Operator. Долговременное хранение: Loki — MinIO + PVC; Prometheus — PVC и при необходимости Thanos + MinIO.

## 2. Инструкция по запуску

### Требования

- Minikube
- kubectl, Helm 3, Helmfile
- Docker
- Рекомендуется: 6–8 GB RAM для Minikube.

### Шаги

1. **Запуск Minikube**
   ```bash
   minikube start --memory=6144 --cpus=2 // у меня этот локи ток так встал
   ```


3. **Развёртывание стека**
   ```bash
   helmfile sync
   ```

4. **Проверка подов**
   ```bash
   kubectl -n muffin-services get pods
   kubectl -n istio-system get pods | grep -E 'loki|promtail|prometheus|grafana|jaeger'
   ```
   Если namespace `muffin-services` создаётся без чарта, добавь метку для Istio:
   ```bash
   kubectl label namespace muffin-services istio-injection=enabled --overwrite
   ```

5. **Доступ к Swagger UI**
   ```bash
   kubectl -n muffin-services port-forward svc/muffin-wallet 8888:80
   ```
   В браузере: **http://localhost:8888/swagger-ui/index.html**

6. **Доступ к UI**
   - **Grafana:** `kubectl -n istio-system port-forward svc/prometheus-grafana 3000:80` → http://localhost:3000 (логин `admin`, пароль такой же).

## 3. Поиск логов по traceId и по уровню

наспамьте запросов для начала чтобы появился трафик
Чтобы получить такой дэш как у меня для этого надо зайти на графану 

создать новый дашборд 
Добавить переменные на доску вида query где выбрать чтобы они соответсвовали лейблам левел и traceId

```json
{namespace="muffin-services", logLevel="$logLevel", traceId = "$trace_id"} |= ``
```
Вставить вот это в строку и все будет корректно конфигуриться 
https://snapshots.raintank.io/dashboard/snapshot/tAaG2BLYsPxJnXnm98G52M1J5sZ7T1z5