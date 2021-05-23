listener "tcp" {
  address          = "NODE_PRIVATE_IP:8200"
  cluster_address  = "127.0.0.1:8201"
  tls_disable      = "true"
}

storage "consul" {
  address = "127.0.0.1:8500"
  path    = "vault/"
}

api_addr = "http://NODE_PRIVATE_IP:8200"
cluster_addr = "https://NODE_PRIVATE_IP:8201"

ui = true

seal "awskms" {
  kms_key_id = "${kms_key_id}"
  region = "${region}"
}
