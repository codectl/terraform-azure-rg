# existing
data "azurerm_resource_group" "this" {
  for_each = {
    for key, val in var.groups : key => val if var.use_existing_groups || val.use_existing_group == true
  }

  name = each.value.name
}

# resource groups
resource "azurerm_resource_group" "this" {
  for_each = var.use_existing_groups ? {} : {
    for key, val in var.groups : key => val if val.use_existing_group != true
  }

  name = coalesce(
    each.value.name, each.key
  )

  location = coalesce(
    each.value.location, var.location
  )

  managed_by = each.value.managed_by

  tags = coalesce(
    each.value.tags, var.tags
  )
}

# locks
resource "azurerm_management_lock" "this" {
  for_each = {
    for k, v in var.groups : k => v if v.management_lock != null
  }

  name = coalesce(
    each.value.management_lock.name, "lock-${each.key}"
  )

  scope = try(
    (var.use_existing_groups || each.value.use_existing_group == true) ? data.azurerm_resource_group.this[each.key].id :
    azurerm_resource_group.this[each.key].id, null
  )

  lock_level = each.value.management_lock.level
  notes      = each.value.management_lock.notes
}
