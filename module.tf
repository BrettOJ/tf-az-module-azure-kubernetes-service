resource "azurerm_kubernetes_cluster" "aks_obj" {
  #lifecycle {
  #  ignore_changes = var.ignore_changes_list
  #}
  timeouts {
    create = "120m"
    delete = "2h"
  }
  name                       = module.aks_name.naming_convention_output[var.naming_convention_info.name].names.0
  dns_prefix                 = module.aks_name.naming_convention_output[var.naming_convention_info.name].names.0
  resource_group_name        = var.resource_group_name
  location                   = var.location
  node_resource_group        = var.aks_node_rg
  automatic_channel_upgrade  = var.automatic_channel_upgrade
  disk_encryption_set_id     = var.disk_encryption_set_id
  azure_policy_enabled       = var.azure_policy_enabled
  role_based_access_control_enabled  = var.role_based_access_control_enabled
  http_application_routing_enabled = var.http_application_routing_enabled

  dynamic "api_server_access_profile" {
    for_each = var.api_server_access_profile == null ? [] : [1]
    content {
      authorized_ip_ranges     = var.api_server_access_profile.authorized_ip_ranges
      subnet_id                = var.api_server_access_profile.subnet_id
      vnet_integration_enabled = var.api_server_access_profile.vnet_integration_enabled
    }
  }

  linux_profile {
    admin_username = var.linux_admin_username
    ssh_key {
      key_data = trimspace(tls_private_key.key.public_key_openssh)
    }
  }

  dynamic "auto_scaler_profile" {
    for_each = var.auto_scaler_profile == null ? [] : [1]

    content {
      balance_similar_node_groups      = var.auto_scaler_profile.balance_similar_node_groups
      expander                         = var.auto_scaler_profile.expander
      max_graceful_termination_sec     = var.auto_scaler_profile.max_graceful_termination_sec
      max_node_provisioning_time       = var.auto_scaler_profile.max_node_provisioning_time
      max_unready_nodes                = var.auto_scaler_profile.max_unready_nodes
      max_unready_percentage           = var.auto_scaler_profile.max_unready_percentage
      new_pod_scale_up_delay           = var.auto_scaler_profile.new_pod_scale_up_delay
      scale_down_delay_after_add       = var.auto_scaler_profile.scale_down_delay_after_add
      scale_down_delay_after_delete    = var.auto_scaler_profile.scale_down_delay_after_delete
      scale_down_delay_after_failure   = var.auto_scaler_profile.scale_down_delay_after_failure
      scan_interval                    = var.auto_scaler_profile.scan_interval
      scale_down_unneeded              = var.auto_scaler_profile.scale_down_unneeded
      scale_down_unready               = var.auto_scaler_profile.scale_down_unready
      scale_down_utilization_threshold = var.auto_scaler_profile.scale_down_utilization_threshold
      empty_bulk_delete_max            = var.auto_scaler_profile.empty_bulk_delete_max
      skip_nodes_with_local_storage    = var.auto_scaler_profile.skip_nodes_with_local_storage
      skip_nodes_with_system_pods      = var.auto_scaler_profile.skip_nodes_with_system_pods
    }
  }


  dynamic "ingress_application_gateway" {
    for_each = var.ingress_application_gateway == null ? [] : [1]
    content {
      gateway_id   = var.ingress_application_gateway.gateway_id
      gateway_name = var.ingress_application_gateway.gateway_name
      subnet_cidr  = var.ingress_application_gateway.subnet_cidr
      subnet_id    = var.ingress_application_gateway.subnet_id
    }
  }

  private_cluster_enabled = var.private_cluster_enabled
  #retrieve the latest version of Kubernetes supported by Azure Kubernetes Service if version is not set
  kubernetes_version = coalesce(var.kubernetes_version, "-1") == "-1" ? data.azurerm_kubernetes_service_versions.current.latest_version : var.kubernetes_version

 default_node_pool {
    name                          = var.default_node_pool.name
    vm_size                       = var.default_node_pool.vm_size
    capacity_reservation_group_id = var.default_node_pool.capacity_reservation_group_id
    custom_ca_trust_enabled       = var.default_node_pool.custom_ca_trust_enabled
    zones                         = var.default_node_pool.zones
    enable_auto_scaling           = var.default_node_pool.enable_auto_scaling
    enable_host_encryption        = var.default_node_pool.enable_host_encryption
    enable_node_public_ip         = var.default_node_pool.enable_node_public_ip
    host_group_id                 = var.default_node_pool.host_group_id
    kubelet_config {
      allowed_unsafe_sysctls    = var.default_node_pool.kubelet_config.allowed_unsafe_sysctls
      container_log_max_line    = var.default_node_pool.kubelet_config.container_log_max_line
      container_log_max_size_mb = var.default_node_pool.kubelet_config.container_log_max_size_mb
      cpu_cfs_quota_enabled     = var.default_node_pool.kubelet_config.cpu_cfs_quota_enabled
      cpu_cfs_quota_period      = var.default_node_pool.kubelet_config.cpu_cfs_quota_period
      cpu_manager_policy        = var.default_node_pool.kubelet_config.cpu_manager_policy
      image_gc_high_threshold   = var.default_node_pool.kubelet_config.image_gc_high_threshold
      image_gc_low_threshold    = var.default_node_pool.kubelet_config.image_gc_low_threshold
      pod_max_pid               = var.default_node_pool.kubelet_config.pod_max_pid
      topology_manager_policy   = var.default_node_pool.kubelet_config.topology_manager_policy
    }
    linux_os_config {
      swap_file_size_mb = var.default_node_pool.linux_os_config.swap_file_size_mb
      sysctl_config  {
        fs_aio_max_nr                      = var.default_node_pool.linux_os_config.sysctl_config.fs_aio_max_nr
        fs_file_max                        = var.default_node_pool.linux_os_config.sysctl_config.fs_file_max
        fs_inotify_max_user_watches        = var.default_node_pool.linux_os_config.sysctl_config.fs_inotify_max_user_watches
        fs_nr_open                         = var.default_node_pool.linux_os_config.sysctl_config.fs_nr_open
        kernel_threads_max                 = var.default_node_pool.linux_os_config.sysctl_config.kernel_threads_max
        net_core_netdev_max_backlog        = var.default_node_pool.linux_os_config.sysctl_config.net_core_netdev_max_backlog
        net_core_optmem_max                = var.default_node_pool.linux_os_config.sysctl_config.net_core_optmem_max
        net_core_rmem_default              = var.default_node_pool.linux_os_config.sysctl_config.net_core_rmem_default
        net_core_rmem_max                  = var.default_node_pool.linux_os_config.sysctl_config.net_core_rmem_max
        net_core_somaxconn                 = var.default_node_pool.linux_os_config.sysctl_config.net_core_somaxconn
        net_core_wmem_default              = var.default_node_pool.linux_os_config.sysctl_config.net_core_wmem_default
        net_core_wmem_max                  = var.default_node_pool.linux_os_config.sysctl_config.net_core_wmem_max
        net_ipv4_ip_local_port_range_max   = var.default_node_pool.linux_os_config.sysctl_config.net_ipv4_ip_local_port_range_max
        net_ipv4_ip_local_port_range_min   = var.default_node_pool.linux_os_config.sysctl_config.net_ipv4_ip_local_port_range_min
        net_ipv4_neigh_default_gc_thresh1  = var.default_node_pool.linux_os_config.sysctl_config.net_ipv4_neigh_default_gc_thresh1
        net_ipv4_neigh_default_gc_thresh2  = var.default_node_pool.linux_os_config.sysctl_config.net_ipv4_neigh_default_gc_thresh2
        net_ipv4_neigh_default_gc_thresh3  = var.default_node_pool.linux_os_config.sysctl_config.net_ipv4_neigh_default_gc_thresh3
        net_ipv4_tcp_fin_timeout           = var.default_node_pool.linux_os_config.sysctl_config.net_ipv4_tcp_fin_timeout
        net_ipv4_tcp_keepalive_intvl       = var.default_node_pool.linux_os_config.sysctl_config.net_ipv4_tcp_keepalive_intvl
        net_ipv4_tcp_keepalive_probes      = var.default_node_pool.linux_os_config.sysctl_config.net_ipv4_tcp_keepalive_probes
        net_ipv4_tcp_keepalive_time        = var.default_node_pool.linux_os_config.sysctl_config.net_ipv4_tcp_keepalive_time
        net_ipv4_tcp_max_syn_backlog       = var.default_node_pool.linux_os_config.sysctl_config.net_ipv4_tcp_max_syn_backlog
        net_ipv4_tcp_max_tw_buckets        = var.default_node_pool.linux_os_config.sysctl_config.net_ipv4_tcp_max_tw_buckets
        net_ipv4_tcp_tw_reuse              = var.default_node_pool.linux_os_config.sysctl_config.net_ipv4_tcp_tw_reuse
        net_netfilter_nf_conntrack_buckets = var.default_node_pool.linux_os_config.sysctl_config.net_netfilter_nf_conntrack_buckets
        net_netfilter_nf_conntrack_max     = var.default_node_pool.linux_os_config.sysctl_config.net_netfilter_nf_conntrack_max
        vm_max_map_count                   = var.default_node_pool.linux_os_config.sysctl_config.vm_max_map_count
        vm_swappiness                      = var.default_node_pool.linux_os_config.sysctl_config.vm_swappiness
        vm_vfs_cache_pressure              = var.default_node_pool.linux_os_config.sysctl_config.vm_vfs_cache_pressure
      }
      transparent_huge_page_defrag  = var.default_node_pool.linux_os_config.transparent_huge_page_defrag
      transparent_huge_page_enabled = var.default_node_pool.linux_os_config.transparent_huge_page_enabled
    }
    fips_enabled = var.default_node_pool.fips_enabled
    kubelet_disk_type   = var.default_node_pool.kubelet_disk_type
    max_pods            = var.default_node_pool.max_pods
    message_of_the_day  = var.default_node_pool.message_of_the_day
    node_network_profile  {
      node_public_ip_tags = var.default_node_pool.node_network_profile.node_public_ip_tags
    }
    node_public_ip_prefix_id     = var.default_node_pool.node_public_ip_prefix_id
    node_labels                  = var.default_node_pool.node_labels
    node_taints                  = var.default_node_pool.node_taints
    only_critical_addons_enabled = var.default_node_pool.only_critical_addons_enabled
    orchestrator_version         = var.default_node_pool.orchestrator_version
    os_disk_size_gb              = var.default_node_pool.os_disk_size_gb
    os_disk_type                 = var.default_node_pool.os_disk_type
    os_sku                       = var.default_node_pool.os_sku
    pod_subnet_id                = var.default_node_pool.pod_subnet_id
    proximity_placement_group_id = var.default_node_pool.proximity_placement_group_id
    scale_down_mode              = var.default_node_pool.scale_down_mode
    type                         = var.default_node_pool.type
    tags                         = var.default_node_pool.tags
    ultra_ssd_enabled            = var.default_node_pool.ultra_ssd_enabled
    upgrade_settings  {
      max_surge = var.default_node_pool.upgrade_settings.max_surge
    }
    vnet_subnet_id   = var.default_node_pool.vnet_subnet_id
    min_count        = var.default_node_pool.min_count
    max_count        = var.default_node_pool.max_count
    node_count       = var.default_node_pool.node_count
    workload_runtime = var.default_node_pool.workload_runtime
  }


  dynamic "identity" {
    for_each = var.aks_cplane_identity_info == null ? [] : [1]
    content {
      type                      = var.aks_cplane_identity_info.type
      identity_ids = var.aks_cplane_identity_info.user_assigned_identity_id #replace(var.aks_cplane_identity_info.user_assigned_identity_id, "resourceGroups", "resourcegroups")
    }
  }

  oms_agent {
    log_analytics_workspace_id = var.diag_object.log_analytics_workspace_id
  }
   
  key_vault_secrets_provider {
    secret_rotation_enabled  = var.key_vault_secrets_provider.secret_rotation_enabled
    secret_rotation_interval = var.key_vault_secrets_provider.secret_rotation_interval
  }

 dynamic "azure_active_directory_role_based_access_control" {

      for_each = var.azure_active_directory_role_based_access_control != null && var.azure_active_directory_role_based_access_control != {} ? [1] : []
      content {
        managed                = var.azure_active_directory_role_based_access_control.managed
        tenant_id              = var.azure_active_directory_role_based_access_control.tenant_id
      }
    }
  

  network_profile {
    network_plugin     = var.network_profile.network_plugin
    network_policy     = var.network_profile.network_policy
    pod_cidr           = var.network_profile.pod_cidr
    service_cidr       = var.network_profile.service_cidr
    dns_service_ip     = var.network_profile.dns_service_ip
    #docker_bridge_cidr = var.network_profile.docker_bridge_cidr
    load_balancer_sku  = var.network_profile.load_balancer_sku
    outbound_type      = var.network_profile.outbound_type
    dynamic "load_balancer_profile" {
      for_each = var.network_profile.load_balancer_profile == null ? [] : [1]
      content {
        outbound_ip_address_ids   = var.network_profile.load_balancer_profile.outbound_ip_prefix_ids
        managed_outbound_ip_count = null
        outbound_ip_prefix_ids    = null
        idle_timeout_in_minutes   = var.network_profile.load_balancer_profile.idle_timeout_in_minutes
      }
    }
  }

  kubelet_identity {
    client_id                 = var.kubelet_identity.client_id
    object_id                 = var.kubelet_identity.object_id
    user_assigned_identity_id = var.kubelet_identity.user_assigned_identity_id
  }

  microsoft_defender {
    log_analytics_workspace_id = var.microsoft_defender.log_analytics_workspace_id
  }

  dynamic "maintenance_window" {
    for_each = var.maintenance_window != null ? [var.maintenance_window] : []
    content {
      dynamic "allowed" {
        for_each = maintenance_window.value.allowed != null ? [maintenance_window.value.allowed] : []
        content {
          day   = allowed.value.day
          hours = allowed.value.hours
        }
      }
      dynamic "not_allowed" {
        for_each = maintenance_window.value.not_allowed != null ? [maintenance_window.value.not_allowed] : []
        content {
          end   = not_allowed.value.end
          start = not_allowed.value.start
        }
      }
    }
  }

  storage_profile {
    blob_driver_enabled         = var.storage_profile.blob_driver_enabled
    disk_driver_enabled         = var.storage_profile.disk_driver_enabled
    disk_driver_version         = var.storage_profile.disk_driver_version
    file_driver_enabled         = var.storage_profile.file_driver_enabled
    snapshot_controller_enabled = var.storage_profile.snapshot_controller_enabled
  }
  
  tags = module.aks_name.naming_convention_output[var.naming_convention_info.name].tags.0
}
