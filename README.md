# Secure an Azure Kubernetes cluster with Azure Active Directory and RBAC

This repository contains Terraform that automates the deployment of an RBAC-enabled Azure Kubernetes Service cluster backed by Azure Active Directory.

This project is originally based on the [jcorioland project](https://github.com/jcorioland/aks-rbac-azure-ad), which is deprecated. This project has been kept up-to-date with the azuread Terraform provider new features (until 0.4.0).

Before getting started, read this [documentation page](https://docs.microsoft.com/en-us/azure/aks/aad-integration) that explains how to configure AKS to use RBAC and Azure Active Directory manually.
This repository proposes Terraform that can automatize the click procedure describes in the previous link.

## Prerequisites

You must have the [Terraform Azuread provider](https://github.com/terraform-providers/terraform-provider-azuread) in at least version **0.4.0**.
```providers.tf
provider "azuread" {
  version = "~>0.4.0"
}
```

This project is written with Terraform **0.12.1**. The Terraform syntax changed a bit since the 0.12.0 version. The principle at stack here is still valid for Terraform versions olders than the 0.12.0, you will just have some rewriting to do.
```
# Terraform 0.11 and former
example = "${var.my_var}"
# Terraform 0.12.0 and later
example = var.my_var
```

## Azure Active Directory

To enable Azure Active Directory authorization with Kubernetes, you need to create two applications:

- A server application, that will work with Azure Active Directory
- A client application, that will work with the server application

It goes this way: the k8s cluster has its own client application. This client application talks to the server application which asks permissions to the Active Directory.
We create in this project a server application and a client application for the cluster.

Multiple AKS clusters can use the same server application, but it's recommended to have one client application per cluster.

The Terraform you will find in this project will create the client and server service principals, applications and passwords.

## Terraform deployment

The `terraform` folder of this repository contains everything you need to deploy the cluster.

First, you may want to edit the [variables.tf](terraform/variables.tf) file to fill the different variables with the right names / values for your environment.

Initialize Terraform.

```bash
$ terraform init
```

Create **JUST ONLY** the two client and server applications/passwords/service principals for this cluster. You only need to target the password resources as the
dependencies will naturally create the applications and the service principals:
```bash
$ terraform apply -target azuread_service_principal_password.server -target azuread_service_principal_password.client
[...]
Apply complete! Resources: 8 added, 0 changed, 0 destroyed.
```

<aside class="warning">
This is now the step which cannot be Terraformed yet and implies some manual actions in the Azure portal (or CLI calls, I will just describe here the click way).

Those actions are **MANDATORY**. The client and server applications must be granted permissions, which **cannot be done with Terraform for now**: go on the Azure portal, choose *Azure Active Directory* in the left menu (or in the services), choose *App registrations* in the submenu, click on the application name, then in the *API permissions* of the application, and click on *Grant admin consent* (do the client application first).
</aside>

Now you can apply to create the whole cluster:
```bash
$ terraform apply
[...wait for the Azure Kubernetes Service cluster to be completed...]
Apply complete! Resources: 26 added, 0 changed, 0 destroyed.
```

## Configure Kubernetes RBAC

The cluster has been deployed and secured using RBAC and Azure Active Directory and the `user.tf` has given ClusterAdmin role to the users you specified in `variables.tf`.

You can also create Role/RoleBinding, ClusterRole/ClusterRoleBinding object using the Kubernetes API to give access to your Azure Active Directory user and groups.

In order to do that, you need to get an administrator Kubernetes configuration file using the Azure CLI:

```bash
az aks get-credentials --resource-group RESOURCE_GROUP_NAME --name CLUSTER_NAME --admin
```

Then apply a ClusterRoleBinding like this one:
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: cluster-admins
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  # This user must exists in your Active Directory
  name: "hello-world@ninja.com"
```

```bash
kubectl apply -f k8s-rbac/cluster-admin-rolebinding.yaml
```

## Connect to the cluster using RBAC and Azure AD

Once all you RBAC objects are defined in Kubernetes, you can get a Kubernetes configuration file that is not admin-enabled using the `az aks get-credentials` command without the `--admin` flag.

```bash
az aks get-credentials --resource-group RESOURCE_GROUP_NAME --name CLUSTER_NAME
```

When you are going to use `kubectl` you are going to be asked to use the Azure Device Login authentication first:

```bash
kubectl get nodes

To sign in, use a web browser to open the page https://microsoft.com/devicelogin and enter the code ABCDEFGHI to authenticate.
```
