output "configure" {
  value = <<CONFIGURE
To get an kubectl context on the cluster:
$ az aks get-credentials --resource-group k8s_cluster --name ${var.cluster_name}
# When first using the kubectl command, you will have to use the Azure device login once:
$ kubectl get nodes
CONFIGURE
}

output "test" {
  value = azurerm_kubernetes_cluster.this.kube_admin_config
}
