variable "name" {
  type        = string
  description = "Name of the Cloud Router; also used as the prefix for the NAT and its static addresses"

  validation {
    condition     = can(regex("^[a-z]([-a-z0-9]{0,51}[a-z0-9])?$", var.name))
    error_message = "var.name must be a valid GCP resource name: lowercase letters, digits and hyphens, starting with a letter, at most 53 characters (leaves room for the -nat-<suffix> address names)"
  }
}

variable "nat_name" {
  type        = string
  description = "Name of the Cloud NAT gateway; defaults to <name>-nat"
  default     = null

  validation {
    condition     = var.nat_name == null || can(regex("^[a-z]([-a-z0-9]{0,61}[a-z0-9])?$", var.nat_name))
    error_message = "var.nat_name must be a valid GCP resource name when set"
  }
}

variable "region" {
  type        = string
  description = "Region to deploy the Cloud Router and NAT in"
  default     = "europe-west2"

  validation {
    condition     = length(trimspace(var.region)) > 0
    error_message = "var.region must be a non-empty string"
  }
}

variable "network" {
  type        = string
  description = "Self link or ID of the VPC network the router is attached to"

  validation {
    condition     = length(trimspace(var.network)) > 0 && !can(regex("/networks/default$", var.network))
    error_message = "var.network must be a non-empty network reference and must not be the default network"
  }
}

variable "description" {
  type        = string
  description = "Human-readable description of the Cloud Router"
  default     = "Cloud Router for Cloud NAT egress"

  validation {
    condition     = length(trimspace(var.description)) > 0
    error_message = "var.description must be a non-empty string"
  }
}

variable "nat_ip_allocate_option" {
  type        = string
  description = "How NAT egress IPs are allocated: MANUAL_ONLY (static google_compute_address resources created by this module, allowlistable) or AUTO_ONLY (Google-allocated, ephemeral)"
  default     = "MANUAL_ONLY"

  validation {
    condition     = contains(["MANUAL_ONLY", "AUTO_ONLY"], var.nat_ip_allocate_option)
    error_message = "var.nat_ip_allocate_option must be one of MANUAL_ONLY or AUTO_ONLY"
  }
}

variable "nat_ip_suffixes" {
  type        = set(string)
  description = "Suffixes of the static external addresses to reserve when nat_ip_allocate_option is MANUAL_ONLY; one address named <name>-nat-<suffix> per entry"
  default     = ["a"]

  validation {
    condition     = length(var.nat_ip_suffixes) >= 1 && length(var.nat_ip_suffixes) <= 300 && alltrue([for s in var.nat_ip_suffixes : can(regex("^[a-z0-9]([-a-z0-9]{0,4}[a-z0-9])?$", s))])
    error_message = "var.nat_ip_suffixes must hold 1-300 entries of lowercase letters, digits and hyphens, at most 6 characters each"
  }
}

variable "subnetworks" {
  type = list(object({
    name                     = string
    source_ip_ranges_to_nat  = optional(list(string), ["ALL_IP_RANGES"])
    secondary_ip_range_names = optional(list(string))
  }))
  description = "Subnetworks (self link or name) to NAT, with the ranges of each to translate. NAT is scoped to exactly this list"

  validation {
    condition     = length(var.subnetworks) > 0 && alltrue([for s in var.subnetworks : length(trimspace(s.name)) > 0])
    error_message = "var.subnetworks must contain at least one subnetwork, each with a non-empty name"
  }

  validation {
    condition = alltrue(flatten([for s in var.subnetworks : [
      for r in s.source_ip_ranges_to_nat : contains(["ALL_IP_RANGES", "PRIMARY_IP_RANGE", "LIST_OF_SECONDARY_IP_RANGES"], r)
    ]]))
    error_message = "var.subnetworks[*].source_ip_ranges_to_nat entries must be ALL_IP_RANGES, PRIMARY_IP_RANGE or LIST_OF_SECONDARY_IP_RANGES"
  }

  validation {
    condition = alltrue([for s in var.subnetworks :
      !contains(s.source_ip_ranges_to_nat, "LIST_OF_SECONDARY_IP_RANGES") || length(coalesce(s.secondary_ip_range_names, [])) > 0
    ])
    error_message = "var.subnetworks entries using LIST_OF_SECONDARY_IP_RANGES must set secondary_ip_range_names"
  }
}

variable "log_filter" {
  type        = string
  description = "Which NAT events are logged: ERRORS_ONLY, TRANSLATIONS_ONLY or ALL. Logging itself is always enabled"
  default     = "ERRORS_ONLY"

  validation {
    condition     = contains(["ERRORS_ONLY", "TRANSLATIONS_ONLY", "ALL"], var.log_filter)
    error_message = "var.log_filter must be one of ERRORS_ONLY, TRANSLATIONS_ONLY or ALL"
  }
}

variable "min_ports_per_vm" {
  type        = number
  description = "Minimum number of NAT ports allocated to each VM"
  default     = 64

  validation {
    condition     = var.min_ports_per_vm >= 2 && var.min_ports_per_vm <= 65536
    error_message = "var.min_ports_per_vm must be between 2 and 65536"
  }
}

variable "idle_timeouts" {
  type = object({
    udp             = optional(number, 30)
    icmp            = optional(number, 30)
    tcp_established = optional(number, 1200)
    tcp_transitory  = optional(number, 30)
    tcp_time_wait   = optional(number, 120)
  })
  description = "NAT connection idle timeouts in seconds, set explicitly rather than relying on provider defaults"
  default     = {}

  validation {
    condition     = alltrue([for v in values(var.idle_timeouts) : v > 0])
    error_message = "var.idle_timeouts values must all be positive numbers of seconds"
  }
}

variable "timeouts" {
  type = object({
    create = optional(string, "20m")
    update = optional(string, "20m")
    delete = optional(string, "20m")
  })
  description = "Terraform operation timeouts applied to the router, NAT and addresses"
  default     = {}

  validation {
    condition     = alltrue([for v in values(var.timeouts) : can(regex("^[0-9]+[smh]$", v))])
    error_message = "var.timeouts values must be durations such as 20m, 600s or 1h"
  }
}

variable "labels" {
  type        = map(string)
  description = "Labels to apply to the static NAT addresses, for cost allocation and ownership tracking"
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.labels : can(regex("^[a-z][a-z0-9_-]{0,62}$", k)) && can(regex("^[a-z0-9_-]{0,63}$", v))])
    error_message = "var.labels keys and values must be lowercase alphanumerics, underscores, or hyphens, 1-63 characters (GCP label constraints)"
  }
}
