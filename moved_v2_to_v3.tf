moved {
  from = azurerm_resource_group.groups
  to   = azurerm_resource_group.this
}

moved {
  from = azurerm_management_lock.lock
  to   = azurerm_management_lock.this
}
