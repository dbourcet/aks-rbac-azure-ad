provider "azurerm" {
  version = "~>1.30.0"
}

provider "azuread" {
  version = "~>0.4.0"
}

provider "random" {
  version = "~>2.1.2"
}

provider "kubernetes" {
  version = "~>1.7.0"

  load_config_file = false

  host = azurerm_kubernetes_cluster.this.kube_admin_config.0.host

  client_certificate     = base64decode(azurerm_kubernetes_cluster.this.kube_admin_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.this.kube_admin_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.this.kube_admin_config.0.cluster_ca_certificate)
}
