# Конфигурация Istio для Muffin Services

## Установленные компоненты

### Istio Core
- **istio-base** - базовые CRD для Istio
- **istiod** - control plane Istio
- **istio-ingress** - Ingress Gateway для внешнего доступа

### Observability
- **Kiali** - визуализация сервисной сетки (порт 20001)
- **Prometheus** - сбор метрик (порт 9090)

## Конфигурация Istio

### 1. Gateway
- **Имя**: `muffin-wallet-gateway`
- **Хост**: `wallet.example.com`
- **Порты**: 80 (HTTP), 443 (HTTPS)
- **TLS**: Использует Secret `muffin-wallet-tls`

### 2. VirtualService для muffin-wallet
- Маршрутизация внешнего трафика через Gateway
- Таймаут: 30s
- Retry: 3 попытки, perTryTimeout: 10s

### 3. VirtualService для muffin-currency
- Внутренняя маршрутизация для `/rate`
- Таймаут: 10s
- Retry: 2 попытки, perTryTimeout: 5s

### 4. ServiceEntry для PostgreSQL
- Позволяет Istio управлять трафиком к PostgreSQL
- Хост: `muffin-postgres.muffin-services.svc.cluster.local`
- Порт: 5432

### 5. PeerAuthentication
- **Режим**: STRICT mTLS
- Применяется ко всем сервисам в namespace `muffin-services`

### 6. AuthorizationPolicy для muffin-currency
- Разрешает доступ только с ServiceAccount `muffin-wallet`
- Методы: GET, POST
- Путь: `/rate*`

### 7. DestinationRule для muffin-wallet
- Connection Pool: maxConnections: 100
- Retry: maxRetries: 3
- Outlier Detection: автоматическое исключение нездоровых инстансов
- mTLS: ISTIO_MUTUAL

### 8. DestinationRule для muffin-currency
- Connection Pool: maxConnections: 100
- Circuit Breaker: consecutiveGatewayErrors: 5
- Retry: maxRetries: 3
- Outlier Detection: автоматическое исключение нездоровых инстансов
- mTLS: ISTIO_MUTUAL

## Автоматическая инжекция Sidecar

Namespace `muffin-services` помечен меткой `istio-injection: enabled` и `sidecar.istio.io/inject: "true"`, что обеспечивает автоматическую инжекцию Istio sidecar proxy во все поды в этом namespace.

## Развертывание

```bash
# Развернуть все компоненты
helmfile sync

# Проверить статус
kubectl get pods -n istio-system
kubectl get pods -n muffin-services

# Проверить Istio конфигурацию
kubectl get gateway,virtualservice,destinationrule,peerauthentication,authorizationpolicy,serviceentry -n muffin-services
```

## Доступ к сервисам через Istio Gateway

### Вариант 1: LoadBalancer + minikube tunnel

1. Запустить minikube tunnel (в отдельном терминале):
```bash
minikube tunnel
```

2. Получить внешний IP:
```bash
kubectl get svc istio-ingressgateway -n istio-system
```

3. Добавить в `/etc/hosts`:
```
<EXTERNAL_IP> wallet.example.com
```

4. Доступ к сервису:
```bash
curl http://wallet.example.com/v1/muffin-wallet/...
```

### Вариант 2: Port-forward (для локального тестирования)

```bash
kubectl port-forward -n istio-system svc/istio-ingressgateway 8080:80
```

Затем доступ через:
```bash
curl -H "Host: wallet.example.com" http://localhost:8080/v1/muffin-wallet/...
```

## Доступ к Observability

### Kiali
```bash
kubectl port-forward -n istio-system svc/kiali 20001:20001
# Открыть http://localhost:20001
```

### Prometheus
```bash
kubectl port-forward -n istio-system svc/prometheus-operated 9090:9090
# Открыть http://localhost:9090
```

## Проверка mTLS

```bash
# Проверить, что mTLS включен
kubectl get peerauthentication -n muffin-services

# Проверить статус mTLS в подах
istioctl proxy-status -n muffin-services
```
