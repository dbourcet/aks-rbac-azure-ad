resource "kubernetes_cluster_role_binding" "admins" {
  metadata {
    name = "cluster-admins"
  }

  role_ref {
    kind      = "ClusterRole"
    name      = "cluster-admin"
    api_group = "rbac.authorization.k8s.io"
  }

  dynamic "subject" {      
    for_each = var.admins  
    content {              
      kind = "User"
      name = subject.value
    }
  }
}
