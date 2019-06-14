resource "kubernetes_cluster_role_binding" "admins" {
  count = length(var.admins)

  metadata {
    name = "cluster-admins"
  }

  role_ref {
    kind      = "ClusterRole"
    name      = "cluster-admin"
    api_group = "rbac.authorization.k8s.io"
  }

  subject {
    kind = "User"
    name = element(var.admins, count.index)
  }
}
