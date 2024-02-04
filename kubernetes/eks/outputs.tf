output "cluster_endpoint" {
  value = module.cluster.cluster_endpoint
}

output "cluster_ca_data" {
  value = module.cluster.cluster_certificate_authority_data
}

output "cluster_oidc_provider" {
  value = module.cluster.oidc_provider
}

output "cluster_oidc_provider_arn" {
  value = module.cluster.oidc_provider_arn
}

output "cluster_oidc_issuer_url" {
  value = module.cluster.cluster_oidc_issuer_url
}

