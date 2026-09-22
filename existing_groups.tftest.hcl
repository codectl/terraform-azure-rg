mock_provider "azurerm" {
  mock_data "azurerm_resource_group" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-mocked-existing"
    }
  }
}

variables {
  location = "westeurope"
}

run "all_groups_are_created" {
  command = plan

  variables {
    use_existing_groups = false

    groups = {
      alpha = {
        name            = "rg-alpha"
        management_lock = { level = "CanNotDelete" }
      }
      beta = {
        name               = "rg-beta"
        use_existing_group = false
      }
    }
  }

  assert {
    condition = length(data.azurerm_resource_group.this) == 0
    error_message = format(
      "no group opts into existing, so the data source must plan 0 instances, got %d: %s",
      length(data.azurerm_resource_group.this),
      jsonencode(sort(keys(data.azurerm_resource_group.this))),
    )
  }

  assert {
    condition = toset(keys(azurerm_resource_group.this)) == toset(["alpha", "beta"])
    error_message = format(
      "every group must be created, expected [alpha, beta], got %s - use_existing_group = false must not exclude a group",
      jsonencode(sort(keys(azurerm_resource_group.this))),
    )
  }

  assert {
    condition = toset(keys(output.groups)) == toset(["alpha", "beta"])
    error_message = format(
      "output \"groups\" must expose both groups, got %s",
      jsonencode(sort(keys(output.groups))),
    )
  }
}

run "global_flag_makes_every_group_existing" {
  command = plan

  variables {
    use_existing_groups = true

    groups = {
      alpha = {
        name            = "rg-alpha"
        management_lock = { level = "CanNotDelete" }
      }
      beta = {
        name               = "rg-beta"
        use_existing_group = false
      }
    }
  }

  assert {
    condition = length(azurerm_resource_group.this) == 0
    error_message = format(
      "use_existing_groups = true must create nothing, got %d managed group(s): %s",
      length(azurerm_resource_group.this),
      jsonencode(sort(keys(azurerm_resource_group.this))),
    )
  }

  assert {
    condition = toset(keys(data.azurerm_resource_group.this)) == toset(["alpha", "beta"])
    error_message = format(
      "use_existing_groups = true must look up every group including ones with use_existing_group = false, expected [alpha, beta], got %s",
      jsonencode(sort(keys(data.azurerm_resource_group.this))),
    )
  }

  assert {
    condition = data.azurerm_resource_group.this["beta"].name == "rg-beta"
    error_message = format(
      "existing group must be looked up by its own name (\"rg-beta\"), got %q",
      data.azurerm_resource_group.this["beta"].name,
    )
  }

  assert {
    condition = azurerm_management_lock.this["alpha"].scope == data.azurerm_resource_group.this["alpha"].id
    error_message = format(
      "lock on an existing group must scope to the data source id, got %q",
      azurerm_management_lock.this["alpha"].scope,
    )
  }

  assert {
    condition = toset(keys(output.groups)) == toset(["alpha", "beta"])
    error_message = format(
      "output \"groups\" must expose both looked-up groups, got %s",
      jsonencode(sort(keys(output.groups))),
    )
  }

  assert {
    condition = alltrue([
      for k, g in output.groups :
      g.id == data.azurerm_resource_group.this[k].id
    ])
    error_message = format(
      "every output group must carry the existing id, got %s",
      jsonencode({ for k, g in output.groups : k => g.id }),
    )
  }
}

run "per_group_flag_splits_existing_and_created" {
  command = plan

  variables {
    use_existing_groups = false

    groups = {
      existing_one = {
        name               = "rg-existing-one"
        use_existing_group = true
        management_lock    = { level = "ReadOnly" }
      }
      created_one = {
        name            = "rg-created-one"
        management_lock = { level = "CanNotDelete" }
      }
      created_two = {
        name = "rg-created-two"
      }
    }
  }

  assert {
    condition = toset(keys(data.azurerm_resource_group.this)) == toset(["existing_one"])
    error_message = format(
      "only the group with use_existing_group = true must be looked up, expected [existing_one], got %s",
      jsonencode(sort(keys(data.azurerm_resource_group.this))),
    )
  }

  assert {
    condition = toset(keys(azurerm_resource_group.this)) == toset(["created_one", "created_two"])
    error_message = format(
      "only the groups without use_existing_group = true must be created, expected [created_one, created_two], got %s",
      jsonencode(sort(keys(azurerm_resource_group.this))),
    )
  }

  assert {
    condition = length(setintersection(keys(data.azurerm_resource_group.this), keys(azurerm_resource_group.this))) == 0
    error_message = format(
      "a group must never be both looked up and created, overlap: %s",
      jsonencode(sort(tolist(setintersection(keys(data.azurerm_resource_group.this), keys(azurerm_resource_group.this))))),
    )
  }

  assert {
    condition = azurerm_management_lock.this["existing_one"].scope == data.azurerm_resource_group.this["existing_one"].id
    error_message = format(
      "lock on the existing group must scope to the data source id, got %q",
      azurerm_management_lock.this["existing_one"].scope,
    )
  }

  assert {
    condition = toset(keys(azurerm_management_lock.this)) == toset(["created_one", "existing_one"])
    error_message = format(
      "a lock must be planned for every group with management_lock regardless of branch, expected [created_one, existing_one], got %s",
      jsonencode(sort(keys(azurerm_management_lock.this))),
    )
  }

  assert {
    condition = toset(keys(output.groups)) == toset(["created_one", "created_two", "existing_one"])
    error_message = format(
      "output \"groups\" must union created and existing groups, got %s",
      jsonencode(sort(keys(output.groups))),
    )
  }

  assert {
    condition = output.groups["existing_one"].id == data.azurerm_resource_group.this["existing_one"].id
    error_message = format(
      "output entry for the existing group must come from the data source, got %q",
      output.groups["existing_one"].id,
    )
  }
}
