locals {
  subnet_id = data.terraform_remote_state.lvl1.outputs.vnet_subnets_005.id.5.id
  akv_id    = data.terraform_remote_state.lvl0.outputs.akv_merlion_output.id
  loga_id   = data.terraform_remote_state.lvl0.outputs.loga_output.id

  des_naming_convention_info = {
    name         = "001"
    project_code = "ml"
    env          = "de"
    zone         = "in"
    agency_code  = "boj"
    tier         = "pp"
  }

  naming_convention_info = {
    name         = "001"
    project_code = "ml"
    env          = "de"
    zone         = "in"
    agency_code  = "boj"
    tier         = "pp"
  }

  aks_naming_convention_info = {
    name         = "001"
    project_code = "ml"
    env          = "de"
    zone         = "in"
    agency_code  = "boj"
    tier         = "pp"
  }

  tags = {
    createdBy = "Terraform"
    project   = "bojtest"
    Owner     = "boj"
  }

}

resource "azurerm_resource_group" "aks_rg" {

  name     = "aks-resources"
  location = "southeastasia"

}

module "azure_disk_encryption_set" {
  source                 = "git::https://dev.azure.com/innersource/Merlion/_git/tf-module-az-disk-encryption-set?ref=main"
  resource_group_name    = azurerm_resource_group.aks_rg.name
  location               = azurerm_resource_group.aks_rg.location
  keyvault_id            = local.akv_id
  tags                   = local.tags
  naming_convention_info = local.des_naming_convention_info
  tenant_id              = "e08ace22-2c12-4de6-8b26-3a5d0f62aed1"
}

module "azure_user_assigned_identity" {
  source                 = "git::https://dev.azure.com/innersource/Merlion/_git/tf-module-az-auth-user-msi?ref=main"
  resource_group_name    = azurerm_resource_group.aks_rg.name
  location               = azurerm_resource_group.aks_rg.location
  naming_convention_info = local.naming_convention_info
  tags                   = local.tags
}

module "azure_aks_service" {
  source                     = "../"
  resource_group_name        = azurerm_resource_group.aks_rg.name
  location                   = var.location
  aks_node_rg                = var.aks_node_rg 
  automatic_channel_upgrade  = var.automatic_channel_upgrade
  disk_encryption_set_id     = module.azure_disk_encryption_set.des_output.id
  azure_policy_enabled       = var.azure_policy_enabled
  private_cluster_enabled     = var.private_cluster_enabled
  naming_convention_info     = local.aks_naming_convention_info
  tags                       = local.tags
  role_based_access_control_enabled = var.role_based_access_control_enabled
  http_application_routing_enabled = var.http_application_routing_enabled

  # api_server_access_profile = {
  #   authorized_ip_ranges     = var.api_server_authorized_ip_ranges
  #   subnet_id                = null
  #   vnet_integration_enabled = var.vnet_integration_enabled
  # }

  oms_agent = {
    log_analytics_workspace_id = local.loga_id
  }

  linux_admin_username = var.linux_admin_username

  auto_scaler_profile = {
    balance_similar_node_groups      = var.balance_similar_node_groups
    expander                         = var.expander
    max_graceful_termination_sec     = var.max_graceful_termination_sec
    max_node_provisioning_time       = var.max_node_provisioning_time
    max_unready_nodes                = var.max_unready_nodes
    max_unready_percentage           = var.max_unready_percentage
    new_pod_scale_up_delay           = var.new_pod_scale_up_delay
    scale_down_delay_after_add       = var.scale_down_delay_after_add
    scale_down_delay_after_delete    = var.scale_down_delay_after_delete
    scale_down_delay_after_failure   = var.scale_down_delay_after_failure
    scan_interval                    = var.scan_interval
    scale_down_unneeded              = var.scale_down_unneeded
    scale_down_unready               = var.scale_down_unready
    scale_down_utilization_threshold = var.scale_down_utilization_threshold
    empty_bulk_delete_max            = var.empty_bulk_delete_max
    skip_nodes_with_local_storage    = var.skip_nodes_with_local_storage
    skip_nodes_with_system_pods      = var.skip_nodes_with_system_pods
  }

  default_node_pool = {
    name                          = var.default_node_pool_name
    vm_size                       = var.default_node_pool_vm_size
    capacity_reservation_group_id = var.default_node_pool_capacity_reservation_group_id
    custom_ca_trust_enabled       = var.default_node_pool_custom_ca_trust_enabled
    zones                         = var.default_node_pool_zones
    enable_auto_scaling           = var.default_node_pool_enable_auto_scaling
    enable_host_encryption        = var.default_node_pool_enable_host_encryption
    enable_node_public_ip         = var.default_node_pool_enable_node_public_ip
    host_group_id                 = var.default_node_pool_host_group_id
    kubelet_config = {
      allowed_unsafe_sysctls    = var.kubelet_config_allowed_unsafe_sysctls
      container_log_max_line    = var.kubelet_config_container_log_max_line
      container_log_max_size_mb = var.kubelet_config_container_log_max_size_mb
      cpu_cfs_quota_enabled     = var.kubelet_config_cpu_cfs_quota_enabled
      cpu_cfs_quota_period      = var.kubelet_config_cpu_cfs_quota_period
      cpu_manager_policy        = var.kubelet_config_cpu_manager_policy
      image_gc_high_threshold   = var.kubelet_config_image_gc_high_threshold
      image_gc_low_threshold    = var.kubelet_config_image_gc_low_threshold
      pod_max_pid               = var.kubelet_config_pod_max_pid
      topology_manager_policy   = var.kubelet_config_topology_manager_policy
    }
    linux_os_config = {
      swap_file_size_mb = var.linux_os_config_swap_file_size_mb
      sysctl_config = {
        fs_aio_max_nr                      = var.sysctl_config_fs_aio_max_nr
        fs_file_max                        = var.sysctl_config_fs_file_max
        fs_inotify_max_user_watches        = var.sysctl_config_fs_inotify_max_user_watches
        fs_nr_open                         = var.sysctl_config_fs_nr_open
        kernel_threads_max                 = var.sysctl_config_kernel_threads_max
        net_core_netdev_max_backlog        = var.sysctl_config_net_core_netdev_max_backlog
        net_core_optmem_max                = var.sysctl_config_net_core_optmem_max
        net_core_rmem_default              = var.sysctl_config_net_core_rmem_default
        net_core_rmem_max                  = var.sysctl_config_net_core_rmem_max
        net_core_somaxconn                 = var.sysctl_config_net_core_somaxconn
        net_core_wmem_default              = var.sysctl_config_net_core_wmem_default
        net_core_wmem_max                  = var.sysctl_config_net_core_wmem_max
        net_ipv4_ip_local_port_range_max   = var.sysctl_config_net_ipv4_ip_local_port_range_max
        net_ipv4_ip_local_port_range_min   = var.sysctl_config_net_ipv4_ip_local_port_range_min
        net_ipv4_neigh_default_gc_thresh1  = var.sysctl_config_net_ipv4_neigh_default_gc_thresh1
        net_ipv4_neigh_default_gc_thresh2  = var.sysctl_config_net_ipv4_neigh_default_gc_thresh2
        net_ipv4_neigh_default_gc_thresh3  = var.sysctl_config_net_ipv4_neigh_default_gc_thresh3
        net_ipv4_tcp_fin_timeout           = var.sysctl_config_net_ipv4_tcp_fin_timeout
        net_ipv4_tcp_keepalive_intvl       = var.sysctl_config_net_ipv4_tcp_keepalive_intvl
        net_ipv4_tcp_keepalive_probes      = var.sysctl_config_net_ipv4_tcp_keepalive_probes
        net_ipv4_tcp_keepalive_time        = var.sysctl_config_net_ipv4_tcp_keepalive_time
        net_ipv4_tcp_max_syn_backlog       = var.sysctl_config_net_ipv4_tcp_max_syn_backlog
        net_ipv4_tcp_max_tw_buckets        = var.sysctl_config_net_ipv4_tcp_max_tw_buckets
        net_ipv4_tcp_tw_reuse              = var.sysctl_config_net_ipv4_tcp_tw_reuse
        net_netfilter_nf_conntrack_buckets = var.sysctl_config_net_netfilter_nf_conntrack_buckets
        net_netfilter_nf_conntrack_max     = var.sysctl_config_net_netfilter_nf_conntrack_max
        vm_max_map_count                   = var.sysctl_config_vm_max_map_count
        vm_swappiness                      = var.sysctl_config_vm_swappiness
        vm_vfs_cache_pressure              = var.sysctl_config_vm_vfs_cache_pressure
      }
      transparent_huge_page_defrag  = var.default_node_pool_transparent_huge_page_defrag
      transparent_huge_page_enabled = var.default_node_pool_transparent_huge_page_enabled
    }
    fips_enabled = var.default_node_pool_fips_enabled
    kubelet_disk_type   = var.default_node_pool_kubelet_disk_type
    max_pods            = var.default_node_pool_max_pods
    message_of_the_day  = var.default_node_pool_message_of_the_day
    node_network_profile = {
      node_public_ip_tags = var.node_network_profile_node_public_ip_tags
    }
    node_public_ip_prefix_id     = var.default_node_pool_node_public_ip_prefix_id
    node_labels                  = var.default_node_pool_node_labels
    node_taints                  = var.default_node_pool_node_taints
    only_critical_addons_enabled = var.default_node_pool_only_critical_addons_enabled
    orchestrator_version         = var.default_node_pool_orchestrator_version
    os_disk_size_gb              = var.default_node_pool_os_disk_size_gb
    os_disk_type                 = var.default_node_pool_os_disk_type
    os_sku                       = var.default_node_pool_os_sku
    pod_subnet_id                = var.default_node_pool_pod_subnet_id
    proximity_placement_group_id = var.default_node_pool_proximity_placement_group_id
    scale_down_mode              = var.default_node_pool_scale_down_mode
    type                         = var.default_node_pool_type
    tags                         = var.default_node_pool_tags
    ultra_ssd_enabled            = var.default_node_pool_ultra_ssd_enabled
    upgrade_settings = {
      max_surge = var.upgrade_settings_max_surge
    }
    vnet_subnet_id   = var.default_node_pool_vnet_subnet_id
    min_count        = var.default_node_pool_min_count
    max_count        = var.default_node_pool_max_count
    node_count       = var.default_node_pool_node_count
    workload_runtime = var.default_node_pool_workload_runtime
  }

  aks_cplane_identity_info = {
    type                      = var.aks_cplane_identity_info_type
    user_assigned_identity_id = [module.azure_user_assigned_identity.msi_output.id]
  }

  key_vault_secrets_provider = {
    secret_rotation_enabled  = var.secret_rotation_enabled
    secret_rotation_interval = var.secret_rotation_interval
  }

  kubelet_identity = {
    client_id                 = var.client_id
    object_id                 = var.object_id
    user_assigned_identity_id = var.user_assigned_identity_id
  }

  microsoft_defender = {
    log_analytics_workspace_id = local.loga_id
  }

  diag_object = {
    log_analytics_workspace_id = local.loga_id
    log                        = [["KubernetesAudit", true, true, 80]]
    metric                     = [["AllMetrics", true, true, 80], ]
  }

  maintenance_window = {
    allowed = {
          day   = var.maintenance_window_allowed_day
          hours = var.maintenance_window_allowed_hours
      }
    not_allowed = {
          end   = var.maintenance_window_not_allowed_end
          start = var.maintenance_window_not_allowed_start
        }
      }

    }
  