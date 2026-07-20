resource "azurerm_private_dns_resolver" "this" {
  name                = var.private_dns_resolver.name
  resource_group_name = var.resource_group_name
  location            = var.location
  virtual_network_id  = var.private_dns_resolver.virtual_network_id

  tags = merge(var.tags, { "Resource Type" = "Private DNS Resolver" })
}

resource "azurerm_private_dns_resolver_inbound_endpoint" "this" {
  name                    = var.private_dns_resolver_inbound_endpoint.name
  resource_group_name     = var.resource_group_name
  location                = var.location
  private_dns_resolver_id = azurerm_private_dns_resolver.this.id

  dynamic "ip_configurations" {
    for_each = var.private_dns_resolver_inbound_endpoint.ip_configurations

    content {
      private_ip_allocation_method = ip_configurations.value.private_ip_allocation_method
      subnet_id                    = ip_configurations.value.subnet_id
      private_ip_address           = ip_configurations.value.private_ip_allocation_method == "Static" ? ip_configurations.value.private_ip_address : null
    }
  }

  tags = merge(var.tags, { "Resource Type" = "Private DNS Resolver Inbound Endpoint" })
}

resource "azurerm_private_dns_resolver_outbound_endpoint" "this" {
  count = var.private_dns_resolver_outbound_endpoint != null ? 1 : 0

  name                    = var.private_dns_resolver_outbound_endpoint.name
  location                = var.location
  private_dns_resolver_id = azurerm_private_dns_resolver.this.id
  subnet_id               = var.private_dns_resolver_outbound_endpoint.subnet_id

  tags = merge(var.tags, { "Resource Type" = "Private DNS Resolver Outbound Endpoint" })
}

resource "azurerm_private_dns_resolver_dns_forwarding_ruleset" "this" {
  for_each = var.private_dns_resolver_forwarding_rulesets

  name                                       = each.key
  resource_group_name                        = var.resource_group_name
  location                                   = var.location
  private_dns_resolver_outbound_endpoint_ids = [azurerm_private_dns_resolver_outbound_endpoint.this[0].id]

  tags = merge(var.tags, { "Resource Type" = "Private DNS Resolver DNS Forwarding Ruleset" })
}

resource "azurerm_private_dns_resolver_forwarding_rule" "this" {
  for_each = local.private_dns_resolver_forwarding_rulesets

  name                      = each.value.ruleset_name
  dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.this[each.key].id
  domain_name               = each.value.domain_name

  dynamic "target_dns_servers" {
    for_each = each.value.target_dns_servers

    content {
      ip_address = target_dns_servers.value.ip_address
      port       = target_dns_servers.value.port
    }
  }
}

resource "azurerm_private_dns_resolver_virtual_network_link" "this" {
  for_each = var.private_dns_resolver_forwarding_rulesets != null ? var.private_dns_resolver_forwarding_rulesets : {}

  name                      = "${var.private_dns_resolver.virtual_network_name}-link"
  dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.this[each.key].id
  virtual_network_id        = var.private_dns_resolver.virtual_network_id
}
