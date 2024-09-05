# Authentication, Authorization, and Identity with Vault 

```
curl -LO raw.githubusercontent.comGoogle-Arcade-Program-2024/main/Authentication%2C%20Authorization%2C%20and%20Identity%20with%20Vault/gsp1005-1.sh

sudo chmod +x gsp1005-1.sh

./gsp1005-1.sh
```
```
export VAULT_TOKEN=""
```
```
export VAULT_ADDR='http://127.0.0.1:8200'

vault status

vault kv put secret/mysql/webapp db_name="users" username="admin" password="passw0rd"

vault auth enable approle

vault policy write jenkins -<<EOF
# Read-only permission on secrets stored at 'secret/data/mysql/webapp'
path "secret/data/mysql/webapp" {
  capabilities = [ "read" ]
}
EOF

vault write auth/approle/role/jenkins token_policies="jenkins" \
    token_ttl=1h token_max_ttl=4h

vault read auth/approle/role/Jenkins

vault read auth/approle/role/jenkins/role-id

vault write -force auth/approle/role/jenkins/secret-id
```
```
vault write auth/approle/login role_id="REPLACE-ROLE-ID" secret_id="REPLACE-SECRET-ID"
```
```
export APP_TOKEN=""
```
```
curl -LO raw.githubusercontent.com/Google-Arcade-Program-2024/main/Authentication%2C%20Authorization%2C%20and%20Identity%20with%20Vault/gsp1005-2.sh

sudo chmod +x gsp1005-2.sh

./gsp1005-2.sh
```

