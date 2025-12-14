# Устранение проблем

## Проблема 1: Таймауты при helmfile sync

### Симптомы
```
Error: UPGRADE FAILED: context deadline exceeded
Error: UPGRADE FAILED: cannot patch "prometheus-..." with kind PrometheusRule: Timeout
```

### Причина
Prometheus создает большое количество ресурсов (PrometheusRule, ServiceMonitor, PodMonitor и т.д.). Helm с `wait: true` ждет готовности всех ресурсов, но из-за большого количества возникает таймаут.

### Решение
1. Убрано `wait: true` для Prometheus и istio-ingress в `helmfile.yaml`
2. После `helmfile sync` подождите 5-10 минут и проверьте статус:
```bash
kubectl get pods -n istio-system
kubectl get pods -n muffin-services
```

3. Если поды не запускаются, проверьте логи:
```bash
kubectl logs -n istio-system -l app=prometheus-operator
kubectl describe pod -n istio-system <pod-name>
```

## Проблема 2: PostgreSQL должен быть в Docker Compose

### Важно
PostgreSQL **не должен** быть в Kubernetes для этого проекта. Он должен быть запущен отдельно в Docker Compose.

### Настройка

1. **Запустить PostgreSQL в Docker Compose:**
```bash
docker-compose up -d postgres
```

2. **Проверить доступность:**
```bash
docker ps | grep postgres
psql -h localhost -U muffin-wallet -d muffin_wallet -c "SELECT 1;"
```

3. **Настроить доступ из minikube:**
   - В minikube используется `host.docker.internal` для доступа к хосту
   - ServiceEntry настроен на `MESH_EXTERNAL` для внешней БД
   - Connection string: `jdbc:postgresql://host.docker.internal:5432/muffin_wallet`

### Если PostgreSQL недоступен из подов

1. Проверить, что PostgreSQL запущен:
```bash
docker ps | grep postgres
```

2. Проверить доступность порта:
```bash
nc -zv localhost 5432
```

3. Для minikube может потребоваться проброс порта:
```bash
minikube service postgres --url
```

Или использовать IP хоста вместо `host.docker.internal`:
```bash
# Получить IP хоста
minikube ssh "route -n get 0.0.0.0 | grep gateway"

# Обновить в istio-config/values.yaml:
# serviceEntry.postgres.host: "<HOST_IP>"
```

## Проблема 3: Istio sidecar не инжектируется

### Проверка
```bash
kubectl get pods -n muffin-services -o jsonpath='{.items[*].spec.containers[*].name}'
```

### Решение
1. Проверить метки namespace:
```bash
kubectl get namespace muffin-services --show-labels
```

2. Должны быть метки:
   - `istio-injection=enabled`
   - `sidecar.istio.io/inject=true`

3. Если меток нет, добавить:
```bash
kubectl label namespace muffin-services istio-injection=enabled sidecar.istio.io/inject=true --overwrite
```

4. Перезапустить поды:
```bash
kubectl delete pods -n muffin-services --all
```

## Проблема 4: Сервис недоступен через Gateway

### Проверка
```bash
# Проверить Gateway
kubectl get gateway -n muffin-services

# Проверить VirtualService
kubectl get virtualservice -n muffin-services

# Проверить Ingress Gateway
kubectl get svc istio-ingressgateway -n istio-system
```

### Решение
1. Запустить minikube tunnel (для LoadBalancer):
```bash
minikube tunnel
```

2. Или использовать port-forward:
```bash
kubectl port-forward -n istio-system svc/istio-ingressgateway 8080:80
curl -H "Host: wallet.example.com" http://localhost:8080/...
```
