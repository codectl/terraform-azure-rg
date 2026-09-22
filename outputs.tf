output "groups" {
  description = "Contains all resource groups, existing and new."
  value       = merge(azurerm_resource_group.this, data.azurerm_resource_group.this)
}
