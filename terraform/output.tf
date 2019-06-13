output "configure" {
  value = <<CONFIGURE
If this is the creation step of the cluster, the client and server Active Directory applications HAVE TO be updated:
go to the Azure portal and click the 'Grant permissions' button for those two apps:
- k8s_client
- k8s_server

Now, get an admin kubectl context on the cluster:
$ az aks get-credentials --resource-group k8s_cluster --name ${var.cluster_name} --admin

Create a RoleBinding/ClusterRoleBinding to allow a user to be admin in your cluster and apply it.
Then ensure that you can use kubectl without admin permissions (when first using the kubectl command, you will have to use the Azure device login once):

$ az aks get-credentials --resource-group k8s_cluster --name ${var.cluster_name}
$ kubectl get nodes
CONFIGURE
}
