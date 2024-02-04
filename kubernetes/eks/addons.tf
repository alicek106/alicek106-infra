locals {
  account_id     = data.aws_caller_identity.current.account_id
  iam_arn_prefix = "arn:aws:iam::${local.account_id}:role/k8s-${var.cluster_name}"
  cluster_autoscaler_image_tag = {
    "1.22" = "v1.22.3"
    "1.23" = "v1.23.1"
    "1.24" = "v1.24.3"
    "1.25" = "v1.25.3"
    "1.26" = "v1.26.6"
    "1.27" = "v1.27.5"
    "1.28" = "v1.28.2"
  }
}

resource "helm_release" "cluster_autoscaler" {
  count            = var.addon_cluster_autoscaler.enabled ? 1 : 0
  name             = "cluster-autoscaler"
  namespace        = "cluster-autoscaler"
  create_namespace = true
  repository       = "https://kubernetes.github.io/autoscaler"
  chart            = "cluster-autoscaler"
  version          = var.addon_cluster_autoscaler.chart_version

  values = [
    templatefile("${path.module}/yaml/cluster-autoscaler-values.yaml", {
      image_tag                  = local.cluster_autoscaler_image_tag[var.cluster_version]
      region                     = var.region,
      service_account_name       = "cluster-autoscaler",
      service_account_role_arn   = "${local.iam_arn_prefix}-cluster-autoscaler"
      cluster_name               = var.cluster_name,
      skip_local_storage         = var.addon_cluster_autoscaler.skip_local_storage
      scale_down_delay_after_add = var.addon_cluster_autoscaler.scale_down_delay_after_add
      scale_down_unneeded_time   = var.addon_cluster_autoscaler.scale_down_unneeded_time
    })
  ]

  depends_on = [
    module.cluster,
  ]
}

resource "helm_release" "argocd" {
  count            = var.addon_argocd.enabled ? 1 : 0
  name             = "argocd"
  namespace        = "argocd"
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.addon_argocd.chart_version

  values = [
    templatefile("${path.module}/yaml/argocd-values.yaml", {
      url           = var.addon_argocd.url,
      admin_enabled = var.addon_argocd.admin_enabled,
    }),
  ]

  depends_on = [
    module.cluster,
  ]
}

resource "helm_release" "argo_rollouts" {
  count            = var.addon_argo_rollouts.enabled ? 1 : 0
  name             = "argo-rollouts"
  namespace        = "argo-rollouts"
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-rollouts"
  version          = var.addon_argo_rollouts.chart_version

  set {
    name  = "dashboard.enabled"
    value = true
  }

  depends_on = [
    module.cluster,
  ]
}

resource "helm_release" "nginx_ingress_controller" {
  count            = var.addon_nginx_ingress_controller.enabled ? 1 : 0
  name             = "nginx-ingress-controller"
  namespace        = "nginx-ingress-controller"
  create_namespace = true
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = var.addon_nginx_ingress_controller.chart_version

  values = [
    templatefile("${path.module}/yaml/nginx-ingress-controller-values.yaml", {
      enable_nlb = var.addon_nginx_ingress_controller.enable_nlb
    })
  ]

  depends_on = [
    module.cluster,
  ]
}

resource "helm_release" "aws_loadbalancer_controller" {
  count            = var.addon_aws_loadbalancer_controller.enabled ? 1 : 0
  name             = "aws-loadbalancer-controller"
  namespace        = "aws-loadbalancer-controller"
  create_namespace = true
  repository       = "https://aws.github.io/eks-charts"
  chart            = "aws-load-balancer-controller"
  version          = var.addon_aws_loadbalancer_controller.chart_version

  values = [
    templatefile("${path.module}/yaml/aws-loadbalancer-controller-values.yaml", {
      cluster_name             = var.cluster_name
      service_account          = "aws-loadbalancer-controller"
      service_account_role_arn = "${local.iam_arn_prefix}-aws-lb-controller"
    })
  ]

  depends_on = [
    module.cluster,
  ]
}
