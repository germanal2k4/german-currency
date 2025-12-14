curl -X 'POST' \
  'http://localhost:8080/v1/muffin-wallet/f1691d7e-9ae7-4195-99ab-2c46fbbf78ad/transaction' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "to_muffin_wallet_id": "682ecb9b-0331-444a-8e6d-19cd7aeab737",
  "amount": 1
}'