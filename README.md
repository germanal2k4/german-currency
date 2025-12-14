# Muffin Services - Kubernetes Deployment with Istio

Проект содержит Helm charts для развертывания микросервисов `muffin-wallet` и `muffin-currency` с полной интеграцией Istio Service Mesh.

## Компоненты

- **muffin-wallet** - основной сервис кошелька
- **muffin-currency** - сервис конвертации валют
- **PostgreSQL** - база данных
- **Istio** - Service Mesh для управления трафиком, безопасности и observability
- **Kiali** - визуализация сервисной сетки
- **Prometheus** - сбор метрик

## Предварительные требования

- Kubernetes кластер версии 1.24+
- kubectl настроен для работы с кластером
- Helm 3.x установлен
- Helmfile установлен

## Быстрый старт

### 1. Развернуть PostgreSQL в Docker Compose

**Важно:** PostgreSQL должен быть запущен отдельно в Docker Compose, а не в Kubernetes.

Если PostgreSQL был развернут в Kubernetes, сначала удалите его:
```bash
./cleanup-postgres.sh
```

Затем запустите PostgreSQL в Docker Compose:

```bash
docker-compose up -d postgres
```

PostgreSQL автоматически создаст необходимое расширение:
- `uuid-ossp` - для генерации UUID

**Важно:** 
- PostgreSQL должен быть доступен на хосте, где запущен minikube
- Для minikube используется `host.minikube.internal:5432`
- Если это не работает, используйте IP хоста (см. TROUBLESHOOTING.md)

### 2. Развернуть все компоненты через Helmfile

```bash
helmfile sync
```

Это автоматически установит:
- Istio (base, istiod, ingress gateway)
- Kiali
- Конфигурацию Istio (Gateway, VirtualService, DestinationRule, AuthorizationPolicy, PeerAuthentication, ServiceEntry)
- Микросервисы muffin-wallet и muffin-currency

**Важно:** 
- PostgreSQL должен быть запущен в Docker Compose отдельно (см. шаг 1)
- ServiceEntry настроен для доступа к внешней БД через `host.minikube.internal:5432`
- Prometheus установлен отдельно для ускорения развертывания (см. ниже)

### 3. Установить Prometheus отдельно (опционально)

Для ускорения развертывания Prometheus установлен отдельно:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack -n istio-system -f istio/prometheus-values.yaml
```

## Доступ к сервисам

### Внешний доступ через Istio Gateway

Сервис `muffin-wallet` доступен через Istio Ingress Gateway по хосту `wallet.example.com`.

**Вариант 1: LoadBalancer + minikube tunnel (рекомендуется)**

1. Запустить minikube tunnel в отдельном терминале:
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

**Вариант 2: Port-forward (для быстрого тестирования)**

```bash
kubectl port-forward -n istio-system svc/istio-ingressgateway 8080:80
```

Затем:
```bash
curl -H "Host: wallet.example.com" http://localhost:8080/v1/muffin-wallet/...
```

### Observability

- **Kiali**: `kubectl port-forward -n istio-system svc/kiali 20001:20001` → http://localhost:20001
- **Prometheus**: `kubectl port-forward -n istio-system svc/prometheus-operated 9090:9090` → http://localhost:9090

## Особенности конфигурации Istio

### Безопасность
- ✅ Включен строгий mTLS для всех сервисов (PeerAuthentication)
- ✅ AuthorizationPolicy ограничивает доступ к `muffin-currency` только с `muffin-wallet`

### Устойчивость к сбоям
- ✅ Circuit Breaker для защиты от каскадных сбоев
- ✅ Retry политики с настраиваемыми таймаутами
- ✅ Outlier Detection для автоматического исключения нездоровых инстансов
- ✅ Connection Pool для управления соединениями

### Observability
- ✅ Метрики Prometheus
- ✅ Визуализация трафика в Kiali
- ✅ Access logs в JSON формате

## Удаление

```bash
helmfile destroy
```
