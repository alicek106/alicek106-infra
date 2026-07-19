module "iam" {
  source            = "./modules/iam"
  cluster_name      = var.cluster_name
  oidc_provider     = module.cluster.oidc_provider
  oidc_provider_arn = module.cluster.oidc_provider_arn
}
