export AWS_ACCESS_KEY_ID="$(VAULT_ADDR="https://vault.lama-corp.space:443" vault kv get -field=access_key infra/terraform/s3)"
export AWS_SECRET_ACCESS_KEY="$(VAULT_ADDR="https://vault.lama-corp.space:443" vault kv get -field=secret_key infra/terraform/s3)"
export VAULT_ADDR="https://vault.lama-corp.space:443"
