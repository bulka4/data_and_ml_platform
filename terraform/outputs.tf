output "sp_client_id" {
  value = module.service_principal.client_id
  sensitive = true
}

output "sp_client_secret" {
  value = module.service_principal.client_secret
  sensitive = true
}

output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
  sensitive = true
}

output "dwh_sa_access_key" {
  value = module.dwh_sa.primary_access_key
  sensitive = true
}

output "system_files_sa_access_key" {
  value = module.system_files_sa.primary_access_key
  sensitive = true
}

output "acr_url" {
  value = module.acr.url
}