terraform {
  required_version = ">= 1.7"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4"
    }
  }
}

module "pdns_resolver" {
  source = "../../"

  resource_group_name = "example-resource-group"
  location            = "eastus"

  private_dns_resolver = {
    name                 = "example-dns-resolver"
    virtual_network_id   = "vnet-id"
    virtual_network_name = "vnet-name"
  }

  private_dns_resolver_inbound_endpoint = {
    name = "inbound-endpoint"
    ip_configurations = [
      {
        private_ip_allocation_method = "Static"
        subnet_id                    = "subnet-id"
        private_ip_address           = "10.0.0.4" # Ensure this is a valid IP within the subnet range
      }
    ]
  }

  private_dns_resolver_outbound_endpoint = {
    name      = "outbound-endpoint"
    subnet_id = "subnet-id"
  }

  private_dns_resolver_forwarding_rulesets = {
    ruleset1 = {
      forwarding_rules = {
        # The map key becomes the name of the forwarding rule. A ruleset holds up to
        # 1000 rules, so several rules per ruleset is the normal case.
        rule1 = {
          domain_name = "example.com."
          target_dns_servers = [{
            ip_address = "10.0.0.1"
            port       = 53
            }
          ]
        }
        rule2 = {
          domain_name = "onprem.local."
          target_dns_servers = [{
            ip_address = "10.0.0.2"
            port       = 53
            }
          ]
        }
      }
    }
  }

  tags = {
    Owner       = "team-name"
    Environment = "production"
  }
}