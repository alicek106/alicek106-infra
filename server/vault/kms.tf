resource "aws_kms_key" "vault" {
  description             = "Vault unseal key"
  deletion_window_in_days = 10

  tags = {
    Name = "vault-auto-unseal"
  }
}

resource "aws_kms_alias" "vault" {
  name          = "alias/vault-auto-unseal"
  target_key_id = aws_kms_key.vault.key_id
}
