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

2. **Сборка и загрузка образов приложений в Minikube**
   ```bash
   docker build -t aadan1lov/muffin-currency:1.0.0 muffin-currency/muffin-currency/
   docker build -t aadan1lov/muffin-wallet:1.2.0 muffin-wallet/muffin-wallet/
   minikube image load aadan1lov/muffin-currency:1.0.0
   minikube image load aadan1lov/muffin-wallet:1.2.0
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

5. **Доступ к Swagger UI (muffin-wallet)**
   ```bash
   kubectl -n muffin-services port-forward svc/muffin-wallet 8888:80
   ```
   В браузере: **http://localhost:8888/swagger-ui/index.html**

6. **Доступ к UI**
   - **Grafana:** `kubectl -n istio-system port-forward svc/prometheus-grafana 3000:80` → http://localhost:3000 (логин `admin`, пароль такой же).
   - **Jaeger:** `kubectl -n istio-system port-forward svc/jaeger 16686:16686` → http://localhost:16686

## 3. Поиск логов по traceId и по уровню

В Grafana выберите источник данных **Loki**.

- **По уровню:** `{namespace="muffin-services"} |~ "ERROR"` или по лейблу `logLevel`: `{namespace="muffin-services", logLevel="INFO"}`.
- **По traceId:** `{namespace="muffin-services"} |= "<trace-id>"` или по лейблу: `{namespace="muffin-services", trace_id="<trace-id>"}`.

В Jaeger по trace ID можно найти трейс; по тому же ID — логи в Loki.
