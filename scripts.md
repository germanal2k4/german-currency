Istiio injection
```bash
   helm install istiod istio/istiod -n istio-system --create-namespace
   curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.20.0 sh -

```
```bash
kubectl get ns muffin-services -o yaml | grep istio-injection
kubectl get pods -w -n muffin-services
```
```bash
kubectl get secret muffin-wallet-tls -n muffin-services -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -noout -dates
kubectl get secret muffin-wallet-tls -n istio-system -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -noout -dates
```
Маршрутизация трафика и проверка хоста
```bash
kubectl get gateway muffin-wallet-gateway -n muffin-services -o yaml
```
```bash
kubectl get svc istio-ingress -n istio-system
```
```bash
cat /etc/hosts/
```
```bash
curl -X 'POST' \
  'http://wallet.example.com/v1/muffin-wallet/23ffa45c-997d-4638-8be5-2e183fcd47d2/transaction' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "to_muffin_wallet_id": "41b0ed8e-8ff0-46e9-afe6-51cab3012a87",
  "amount": 10
}'
INGRESS_IP=$(kubectl get svc istio-ingress -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl -X 'POST' \
  'https://wallet.example.com/v1/muffin-wallet/23ffa45c-997d-4638-8be5-2e183fcd47d2/transaction' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -k \
  -d '{
  "to_muffin_wallet_id": "41b0ed8e-8ff0-46e9-afe6-51cab3012a87",
  "amount": 10
}'
```
Проверка Kiali
```bash
kubectl -n istio-system port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090
```
```bash
sh \     
  -L 3000:localhost:9090 \        
  german@89.169.187.59
```

Security
```bash
kubectl get peerauthentication -o yaml -n muffin-services
kubectl -n muffin-services logs muffin-wallet-7f457b549f-md985 -c istio-proxy | grep -i "tls\|mtls\|handshake"
```
```bash
kubectl get authorizationpolicy -n muffin-services -o yaml
```
Resilence
```bash
kubectl get destinationrule muffin-currency -n muffin-services -o yaml
kubectl get destinationrule muffin-wallet -n muffin-services -o yaml
```
```bash
kubectl get serviceentry -o yaml -n muffin-services
kubectl -n muffin-services logs muffin-wallet-7f457b549f-md985 -c istio-proxy
```
```bash
kubectl get virtualservice -o yaml -n muffin-services
kubectl -n muffin-services logs muffin-wallet-7f457b549f-md985 -c istio-proxy --tail=20 | grep "muffin-currency"
kubectl -n muffin-services logs muffin-wallet-7f457b549f-md985 -c istio-proxy --tail=50 | grep -i "5432"
```