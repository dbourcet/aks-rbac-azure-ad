resource "azurerm_resource_group" "this" {
  name     = "k8s_cluster"
  location = var.location
}

resource "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.k8s_version

  agent_pool_profile {
    name            = var.agent_name
    count           = var.agent_count
    vm_size         = "Standard_DS2_v2"
    os_disk_size_gb = 30
    os_type         = "Linux"
  }

  service_principal {
    client_id     = azuread_application.client.application_id
    client_secret = azuread_service_principal_password.client.value
  }

  linux_profile {
    admin_username = "mypseudo"

    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }

  role_based_access_control {
    enabled = true

    azure_active_directory {
      client_app_id     = azuread_application.client.application_id
      server_app_id     = azuread_application.server.application_id
      server_app_secret = azuread_service_principal_password.server.value
    }
  }
}
