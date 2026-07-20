variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "location"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)

  default = {}
}

variable "private_dns_resolver" {
  description = "Private DNS resolver configuration"
  type = object({
    name                 = string
    virtual_network_id   = string
    virtual_network_name = string
  })
}

variable "private_dns_resolver_inbound_endpoint" {
  description = "Private DNS resolver inbound endpoint configuration"
  type = object({
    name = string
    ip_configurations = list(object({
      private_ip_allocation_method = optional(string, "Static")
      subnet_id                    = string
      private_ip_address           = optional(string, null)
    }))
  })
}

variable "private_dns_resolver_outbound_endpoint" {
  description = "Private DNS resolver outbound endpoint configuration"
  type = object({
    name      = string
    subnet_id = string
  })

  default = null
}

variable "private_dns_resolver_forwarding_rulesets" {
  description = "Private DNS resolver forwarding ruleset configurations"
  type = map(object({
    forwarding_rules = map(object({
      domain_name = optional(string, null)
      target_dns_servers = list(object({
        ip_address = optional(string, null)
        port       = optional(number, 53)
      }))
    }))
  }))

  default = {}
}
