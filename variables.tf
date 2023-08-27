variable "resource_group_name" {
  description = "(Required) Name of the resource group where to create the aks"
  type        = string
}

variable "location" {
  description = "(Required) Define the region where the resource groups will be created"
  type        = string
}

variable "enable_rbac" {
  description = "(Required) Enable RBAC"
  default     = true
  type        = bool
}

variable "automatic_channel_upgrade" {
  type        = string
  description = "set the upgrade option for the cluster"
  default     = "none"
}

variable "azure_policy_enabled" {
  type    = bool
  default = false
}
variable "aks_node_rg" {
  description = "(Optional) The name of the Resource Group where the the Kubernetes Nodes should exist."
}

variable "private_cluster_enabled" {
  type = bool
  default = false
}

variable "api_server_access_profile" {
  description = "API server accesss profile"
  type = object({
    authorized_ip_ranges        = list(string)
    subnet_id                   = string
    vnet_integration_enabled    = string
    }
  )
  default = null
}

variable "auto_scaler_profile" {
  type = object({
    balance_similar_node_groups      = bool
    expander                         = string
    max_graceful_termination_sec     = number
    max_node_provisioning_time       = string
    max_unready_nodes                = number
    max_unready_percentage           = number
    new_pod_scale_up_delay           = string
    scale_down_delay_after_add       = string
    scale_down_delay_after_delete    = string
    scale_down_delay_after_failure   = string
    scan_interval                    = string
    scale_down_unneeded              = string
    scale_down_unready               = string
    scale_down_utilization_threshold = number
    empty_bulk_delete_max            = number
    skip_nodes_with_local_storage    = bool
    skip_nodes_with_system_pods      = bool
  })
  default = {
    balance_similar_node_groups      = false
    expander                         = "random"
    max_graceful_termination_sec     = 600
    max_node_provisioning_time       = "15m"
    max_unready_nodes                = 3
    max_unready_percentage           = 45
    new_pod_scale_up_delay           = "10s"
    scale_down_delay_after_add       = "10m"
    scale_down_delay_after_delete    = "10s"
    scale_down_delay_after_failure   = "3m"
    scan_interval                    = "10s"
    scale_down_unneeded              = "10m"
    scale_down_unready               = "20m"
    scale_down_utilization_threshold = 0.5
    empty_bulk_delete_max            = 10
    skip_nodes_with_local_storage    = true
    skip_nodes_with_system_pods      = true
  }
}

variable "default_node_pool" {
  description = "(Optional) List of agent_pools profile for multiple node pools"
  type = object({
    name                 = string
    vm_size              = string
    capacity_reservation_group_id = string #Specifies the ID of the Capacity Reservation Group within which this AKS Cluster should be created
    custom_ca_trust_enabled  = string #This requires that the Preview Feature Microsoft.ContainerService/CustomCATrustPreview is enabled and the Resource Provider is re-register
    zones   = list(number)  #replaces 
    enable_auto_scaling  = bool #If you're using AutoScaling, you may wish to use Terraform's ignore_changes functionality to ignore changes to the node_count field.
    enable_host_encryption = bool
    enable_node_public_ip = bool
    host_group_id = string
    kubelet_config = object({
      allowed_unsafe_sysctls    = list(string)
      container_log_max_line    = number
      container_log_max_size_mb = number
      cpu_cfs_quota_enabled     = bool
      cpu_cfs_quota_period      = string
      cpu_manager_policy        = string
      image_gc_high_threshold   = number
      image_gc_low_threshold    = number
      pod_max_pid               = number
      topology_manager_policy   = string
      })
    linux_os_config = object({
     swap_file_size_mb = string
     sysctl_config = object({
         fs_aio_max_nr = number # The sysctl setting fs.aio-max-nr. Must be between 65536 and 6553500. Changing this forces a new resource to be created.
         fs_file_max = number # The sysctl setting fs.file-max. Must be between 8192 and 12000500. Changing this forces a new resource to be created.
         fs_inotify_max_user_watches = number # The sysctl setting fs.inotify.max_user_watches. Must be between 781250 and 2097152. Changing this forces a new resource to be created.
         fs_nr_open = number # The sysctl setting fs.nr_open. Must be between 8192 and 20000500. Changing this forces a new resource to be created.
         kernel_threads_max = number # The sysctl setting kernel.threads-max. Must be between 20 and 513785. Changing this forces a new resource to be created.
         net_core_netdev_max_backlog =  number # The sysctl setting net.core.netdev_max_backlog. Must be between 1000 and 3240000. Changing this forces a new resource to be created.
         net_core_optmem_max = number # The sysctl setting net.core.optmem_max. Must be between 20480 and 4194304. Changing this forces a new resource to be created.
         net_core_rmem_default = number # The sysctl setting net.core.rmem_default. Must be between 212992 and 134217728. Changing this forces a new resource to be created.
         net_core_rmem_max = number # The sysctl setting net.core.rmem_max. Must be between 212992 and 134217728. Changing this forces a new resource to be created.
         net_core_somaxconn = number # The sysctl setting net.core.somaxconn. Must be between 4096 and 3240000. Changing this forces a new resource to be created.
         net_core_wmem_default = number # The sysctl setting net.core.wmem_default. Must be between 212992 and 134217728. Changing this forces a new resource to be created.
         net_core_wmem_max = number # The sysctl setting net.core.wmem_max. Must be between 212992 and 134217728. Changing this forces a new resource to be created.
         net_ipv4_ip_local_port_range_max = number # The sysctl setting net.ipv4.ip_local_port_range max value. Must be between 1024 and 60999. Changing this forces a new resource to be created.
         net_ipv4_ip_local_port_range_min = number # The sysctl setting net.ipv4.ip_local_port_range min value. Must be between 1024 and 60999. Changing this forces a new resource to be created.
         net_ipv4_neigh_default_gc_thresh1 = number # The sysctl setting net.ipv4.neigh.default.gc_thresh1. Must be between 128 and 80000. Changing this forces a new resource to be created.
         net_ipv4_neigh_default_gc_thresh2 = number # The sysctl setting net.ipv4.neigh.default.gc_thresh2. Must be between 512 and 90000. Changing this forces a new resource to be created.
         net_ipv4_neigh_default_gc_thresh3 = number # The sysctl setting net.ipv4.neigh.default.gc_thresh3. Must be between 1024 and 100000. Changing this forces a new resource to be created.
         net_ipv4_tcp_fin_timeout = number # The sysctl setting net.ipv4.tcp_fin_timeout. Must be between 5 and 120. Changing this forces a new resource to be created.
         net_ipv4_tcp_keepalive_intvl = number # The sysctl setting net.ipv4.tcp_keepalive_intvl. Must be between 10 and 75. Changing this forces a new resource to be created.
         net_ipv4_tcp_keepalive_probes = number # The sysctl setting net.ipv4.tcp_keepalive_probes. Must be between 1 and 15. Changing this forces a new resource to be created.
         net_ipv4_tcp_keepalive_time = number # The sysctl setting net.ipv4.tcp_keepalive_time. Must be between 30 and 432000. Changing this forces a new resource to be created.
         net_ipv4_tcp_max_syn_backlog = number # The sysctl setting net.ipv4.tcp_max_syn_backlog. Must be between 128 and 3240000. Changing this forces a new resource to be created.
         net_ipv4_tcp_max_tw_buckets = number # The sysctl setting net.ipv4.tcp_max_tw_buckets. Must be between 8000 and 1440000. Changing this forces a new resource to be created.
         net_ipv4_tcp_tw_reuse = bool # The sysctl setting net.ipv4.tcp_tw_reuse. Changing this forces a new resource to be created.
         net_netfilter_nf_conntrack_buckets = number # The sysctl setting net.netfilter.nf_conntrack_buckets. Must be between 65536 and 147456. Changing this forces a new resource to be created.
         net_netfilter_nf_conntrack_max = number # The sysctl setting net.netfilter.nf_conntrack_max. Must be between 131072 and 1048576. Changing this forces a new resource to be created.
         vm_max_map_count = number # The sysctl setting vm.max_map_count. Must be between 65530 and 262144. Changing this forces a new resource to be created.
         vm_swappiness = number # The sysctl setting vm.swappiness. Must be between 0 and 100. Changing this forces a new resource to be created.
         vm_vfs_cache_pressure = number # The sysctl setting vm.vfs_cache_pressure. Must be between 0 and 100. Changing this forces a new resource to be created.
          })
          transparent_huge_page_defrag = string 
          transparent_huge_page_enabled = string
        })
    fips_enabled = bool
    kubelet_disk_type = string #The type of disk used by kubelet. Possible values are OS and Temporary.
    max_pods             = number
    message_of_the_day = string # A base64-encoded string which will be written to /etc/motd after decoding.
    node_network_profile = object ({
      node_public_ip_tags = map(string)    
    })
    node_public_ip_prefix_id = string
    node_labels = map(string)
    node_taints = list(string)
    only_critical_addons_enabled = bool
    orchestrator_version = string
    os_disk_size_gb      = number
    os_disk_type         = string # Possible values are Ephemeral and Managed. Defaults to Managed
    os_sku               = string # Possible values include: Ubuntu, CBLMariner, Mariner, Windows2019, Windows2022. If not specified, the default is Ubuntu if OSType=Linux or Windows2019 if OSType=Windows
    pod_subnet_id        = string
    proximity_placement_group_id = string
    scale_down_mode = string # Allowed values are Delete and Deallocate. Defaults to Delete.
    type = string #  Possible values are AvailabilitySet and VirtualMachineScaleSets. Defaults to VirtualMachineScaleSets.
    tags = map(string)
    ultra_ssd_enabled = bool
    upgrade_settings = object({
      max_surge = number
    })
    vnet_subnet_id = string
    #enable_auto_scaling is set to true, then the following fields can also be configured:
    min_count            = number
    max_count            = number
    node_count           = number #must be between 1 and 1000.
    workload_runtime     = string # Possible values are OCIContainer.
  })
  default = {
    name                 = "default"
    vm_size              = "Standard_D2s_v3"
    capacity_reservation_group_id = null 
    custom_ca_trust_enabled  = null
    zones   = [1, 2, 3]
    enable_auto_scaling  = true
    enable_host_encryption = null
    enable_node_public_ip = null
    host_group_id = null
    kubelet_config = {
        allowed_unsafe_sysctls    = null
        container_log_max_line    = null
        container_log_max_size_mb = null
        cpu_cfs_quota_enabled     = null
        cpu_cfs_quota_period      = null
        cpu_manager_policy        = null
        image_gc_high_threshold   = null
        image_gc_low_threshold    = null
        pod_max_pid               = null
        topology_manager_policy   = null
      }
    linux_os_config = {
     swap_file_size_mb = null
     sysctl_config = {
         fs_aio_max_nr = null 
         fs_file_max = null
         fs_inotify_max_user_watches = null 
         fs_nr_open = null 
         kernel_threads_max = null
         net_core_netdev_max_backlog =  null 
         net_core_optmem_max = null 
         net_core_rmem_default = null 
         net_core_rmem_max = null  
         net_core_somaxconn = null 
         net_core_wmem_default = null 
         net_core_wmem_max = null 
         net_ipv4_ip_local_port_range_max = null 
         net_ipv4_ip_local_port_range_min = null
         net_ipv4_neigh_default_gc_thresh1 = null 
         net_ipv4_neigh_default_gc_thresh2 = null 
         net_ipv4_neigh_default_gc_thresh3 = null 
         net_ipv4_tcp_fin_timeout = null 
         net_ipv4_tcp_keepalive_intvl = null 
         net_ipv4_tcp_keepalive_probes = null 
         net_ipv4_tcp_keepalive_time = null 
         net_ipv4_tcp_max_syn_backlog = null 
         net_ipv4_tcp_max_tw_buckets = null 
         net_ipv4_tcp_tw_reuse = null 
         net_netfilter_nf_conntrack_buckets = null 
         net_netfilter_nf_conntrack_max = null 
         vm_max_map_count = null 
         vm_swappiness = null 
         vm_vfs_cache_pressure = null 
          }
      transparent_huge_page_defrag = null 
      transparent_huge_page_enabled = null
      }
    fips_enabled = false
    kubelet_disk_type = "OS" 
    max_pods             = 50
    message_of_the_day = null
    node_network_profile = {
      node_public_ip_tags = null    
    }
    node_public_ip_prefix_id = null
    node_labels = null
    node_taints = null
    only_critical_addons_enabled = null
    orchestrator_version = null
    os_disk_size_gb      = 100
    os_disk_type         = "managed"
    os_sku               = "Ubuntu"
    pod_subnet_id        = null
    proximity_placement_group_id = null
    scale_down_mode = "Delete"
    type = "VirtualMachineScaleSets"
    tags = null
    ultra_ssd_enabled = null
    upgrade_settings = {
      max_surge = null
    }
    vnet_subnet_id = null
    min_count            = 1
    max_count            = 3
    node_count           = 3
    workload_runtime     = "OCIContainer"
  }
}

variable "linux_admin_username" {
  description = "(Optional) User name for authentication to the Kubernetes linux agent virtual machines in the cluster."
  type        = string
  default     = "azureuser"
}

variable "kubernetes_version" {
  description = "(Optional) Version of Kubernetes specified when creating the AKS managed cluster"
  default     = ""
}

variable "http_application_routing_enabled" {
  type = bool
}

variable "role_based_access_control_enabled" {
  type = bool
  default = false
}

variable "network_profile" {
  description = "(Optional) Sets up network profile for Advanced Networking."
  type = object({
    network_plugin        = string #supported values are azure, kubenet and none
    network_mode          = string # can only be set to bridge for existing Kubernetes Clusters and cannot be used to provision new Clusters
    network_policy        = string
    dns_service_ip        = string
    docker_bridge_cidr    = string
    ebpf_data_plane       = string # optional Possible value is cilium.
    network_plugin_mode   = string # Possible values are loadBalancer, userDefinedRouting, managedNATGateway and userAssignedNATGateway
    outbound_type         = string
    pod_cidr              = string
    pod_cidrs             = list(string)
    service_cidr          = string
    service_cidrs         = list(string)
    ip_versions           = list(string)
    load_balancer_sku     = string #Possible values are basic and standard. Defaults to standard
    load_balancer_profile = object({
        idle_timeout_in_minutes = number
        managed_outbound_ip_count = number
        managed_outbound_ipv6_count = number #anaged_outbound_ipv6_count requires dual-stack networking. To enable dual-stack networking the Preview Feature Microsoft.ContainerService/AKS-EnableDualStack needs to be enabled and the Resource Provider re-registered,
        outbound_ip_address_ids = string
        outbound_ip_prefix_ids  = string
        outbound_ports_allocated = number
       })
    nat_gateway_profile   = object({
      idle_timeout_in_minutes    = number # Desired outbound flow idle timeout in minutes for the cluster load balancer. Must be between 4 and 120 inclusive. Defaults to 4.
      managed_outbound_ip_count  = number # Count of desired managed outbound IPs for the cluster load balancer. Must be between 1 and 100 inclusive.
    })
  })
  default = {
    # Use azure-cni for advanced networking
    network_plugin = "kubenet"
    pod_cidr       = "10.244.0.0/16"
    # Sets up network policy to be used with Azure CNI. Currently supported values are calico and azure." 
    network_policy     = "calico"
    service_cidr       = "10.100.0.0/16"
    dns_service_ip     = "10.100.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
    # Specifies the SKU of the Load Balancer used for this Kubernetes Cluster. Use standard for when enable agent_pools availability_zones.
    load_balancer_sku = "standard"
    ebpf_data_plane = null 
    ip_versions = null
    load_balancer_profile = null
    nat_gateway_profile = null
    network_mode = null
    network_plugin_mode = null
    outbound_type = null
    pod_cidrs = null
    service_cidrs = null
  }
}

variable "diag_object" {
  description = "contains the logs and metrics for diagnostics"
  type = object({
    log_analytics_workspace_id = string
    log                        = list(tuple([string, bool, number]))
    metric                     = list(tuple([string, bool, number]))
  })
}

variable "naming_convention_info" {
  description = "(Required) Specify the naming convention information to the resource."
  type = object({
    name         = string
    agency_code  = string
    project_code = string
    env          = string
    zone         = string
    tier         = string
  })
}

variable "tags" {
  type        = map(string)
  description = "Specify the tags to the resource. Additional tags will be appended based on the convention"
}

variable "disk_encryption_set_id" {
  default = null
}

variable "aks_cplane_identity_info" {
  type = object({
    type                      = string
    user_assigned_identity_id = list(string)
  })
  description = "(Required) Specify if AKS shld use managed identity for the control plane"
}

variable "azure_active_directory_role_based_access_control" {
  description = "specify the Azure Active directory profile"
  default     = null
  type = object({
    managed                = bool
    tenant_id              = string
  })
}

variable "key_vault_secrets_provider" {
  type = object({
    secret_rotation_enabled  = bool
    secret_rotation_interval = string
  })
}


variable "kubelet_identity" {
  type = object({
    client_id                 = string
    object_id                 = string
    user_assigned_identity_id = string
  })
  default = {
    client_id                 = null
    object_id                 = null
    user_assigned_identity_id = null
  }
}

variable "maintenance_window" {
  type = object({
    allowed = object({
      day   = string
      hours = list(number)
    })
    not_allowed = object({
      end   = string
      start = string
    })
  })
  default = {
    allowed     = null
    not_allowed = null
  }
}


variable "microsoft_defender" {
  type = object({
  log_analytics_workspace_id = string
  })
}

variable "oms_agent" {
  type = object({
  log_analytics_workspace_id = string
  })
}

variable "ingress_application_gateway" {
  type = object({
  gateway_id  = string # The ID of the Application Gateway to integrate with the ingress controller of this Kubernetes Cluster. See this page for further details.
  gateway_name  = string # The name of the Application Gateway to be used or created in the Nodepool Resource Group, which in turn will be integrated with the ingress controller of this Kubernetes Cluster. See this page for further details.
  subnet_cidr  = string # The subnet CIDR to be used to create an Application Gateway, which in turn will be integrated with the ingress controller of this Kubernetes Cluster. See this page for further details.
  subnet_id  = string # The ID of the subnet on which to create an Application Gateway, which in turn will be integrated with the ingress controller of this Kubernetes Cluster. See this page for further details.
  })
  default = null
}

variable "storage_profile" {
  type = object({
  blob_driver_enabled  = bool # Is the Blob CSI driver enabled? Defaults to false.
  disk_driver_enabled  = bool # Is the Disk CSI driver enabled? Defaults to true.
  disk_driver_version  = string # Disk CSI Driver version to be used. Possible values are v1 and v2. Defaults to v1.
  file_driver_enabled  = bool # Is the File CSI driver enabled? Defaults to true.
  snapshot_controller_enabled  = bool # Is the Snapshot Controller enabled? Defaults to true.
})
default = {
  blob_driver_enabled = false
  disk_driver_enabled = true
  disk_driver_version = "v1"
  file_driver_enabled = true
  snapshot_controller_enabled = true
}
}
  






