# Resource Groups

This terraform module enables the efficient creation and management of azure resource groups. By offering customizable options for the name, location, management locks and tags, it brings granular control over your azure environment.

## Features

Provides support for both single and multiple resource groups, allowing flexible resource management.

Implements optional management locks for enhanced security

Supports leveraging existing resource groups

Utilization of terratest for robust validation.

Falls back to the map key as the resource group name when no explicit name is given.

<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 5.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (5.0.1)

## Resources

The following resources are used by this module:

- [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) (resource)
- [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) (data source)

## Required Inputs

The following input variables are required:

### <a name="input_groups"></a> [groups](#input\_groups)

Description: Contains all resource group configuration

Type:

```hcl
map(object({
    name               = optional(string)
    location           = optional(string)
    managed_by         = optional(string)
    tags               = optional(map(string))
    use_existing_group = optional(bool)
    management_lock = optional(object({
      name  = optional(string)
      level = string
      notes = optional(string)
    }))
  }))
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_location"></a> [location](#input\_location)

Description: default azure location to be used.

Type: `string`

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: tags to be added to the resources

Type: `map(string)`

Default: `{}`

### <a name="input_use_existing_groups"></a> [use\_existing\_groups](#input\_use\_existing\_groups)

Description: use existing resource groups globally

Type: `bool`

Default: `false`

## Outputs

The following outputs are exported:

### <a name="output_groups"></a> [groups](#output\_groups)

Description: Contains all resource groups, existing and new.
<!-- END_TF_DOCS -->

## Goals

For more information, please see our [goals and non-goals](./GOALS.md).

## Testing

For more information, please see our testing [guidelines](./TESTING.md)

## Notes

Using a dedicated module, we've developed a naming convention for resources that's based on specific regular expressions for each type, ensuring correct abbreviations and offering flexibility with multiple prefixes and suffixes.

Full examples detailing all usages, along with integrations with dependency modules, are located in the examples directory.

To update the module's documentation run `make doc`

## Contributors

We welcome contributions from the community! Whether it's reporting a bug, suggesting a new feature, or submitting a pull request, your input is highly valued.

For more information, please see our contribution [guidelines](./CONTRIBUTING.md). <br><br>

<a href="https://github.com/cloudnationhq/terraform-azure-rg/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=cloudnationhq/terraform-azure-rg" />
</a>

## Authors

Module is maintained by [these awesome contributors](https://github.com/cloudnationhq/terraform-azure-rg/graphs/contributors).

## License

MIT Licensed. See [LICENSE](./LICENSE) for full details.

## References

- [Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal)
- [Rest Api](https://learn.microsoft.com/en-us/rest/api/resources/resource-groups)
