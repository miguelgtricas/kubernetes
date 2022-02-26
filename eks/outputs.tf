#output "kubectl_configuration" {
#  description = "The configuration need for kubectl to interact with EKS"
#  value       = module.eks.kubeconfig
#}
#
#output "webapp_url" {
#  description = "The URL of the webapp"
#  value = "URL of the app (it may take some time for pods to be fully operational): http://${kubernetes_service.webapp-service.load_balancer_ingress[0].hostname}"
#}
