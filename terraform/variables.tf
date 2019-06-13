variable "location" {
  description = "The location where the Managed Kubernetes Cluster should be created."
  type        = string
  default     = "France Central"
}

variable "cluster_name" {
  description = "The name of the Managed Kubernetes Cluster to create."
  type        = "string"
  default     = "my_cluster"
}

variable "dns_prefix" {
  description = "DNS prefix specified when creating the managed cluster. "
  type        = string
  default     = "mybusiness"
}

variable "k8s_version" {
  description = "Version of Kubernetes specified when creating the AKS managed cluster."
  type        = string
  default     = "1.13.5"
}

variable "agent_name" {
  # The name must not contain special characters.
  description = "Unique name of the Agent Pool Profile in the context of the Subscription and Resource Group."
  type        = string
  default     = "mybusiness"
}

variable "agent_count" {
  description = "Number of Agents (VMs) in the Pool."
  type        = number
  default     = 1
}

variable "ssh_public_key" {
  description = "ssh key to use to connect to the node."
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}
