# terraform-gcp-router-nat

[![Build Status](https://github.com/JamesWoolfenden/terraform-gcp-router-nat/workflows/Verify/badge.svg?branch=main)](https://github.com/JamesWoolfenden/terraform-gcp-router-nat/actions)
[![Latest Release](https://img.shields.io/github/release/JamesWoolfenden/terraform-gcp-router-nat.svg)](https://github.com/JamesWoolfenden/terraform-gcp-router-nat/releases/latest)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/JamesWoolfenden/terraform-gcp-router-nat.svg?label=latest)](https://github.com/JamesWoolfenden/terraform-gcp-router-nat/releases/latest)
![Terraform Version](https://img.shields.io/badge/tf-%3E%3D1.5.0-blue.svg)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)

Terraform module for a Cloud Router with Cloud NAT. NAT is scoped to an explicit list of subnetworks (never the whole VPC), egress uses static `google_compute_address` IPs by default (or Google-allocated `AUTO_ONLY`), NAT logging is always on (`ERRORS_ONLY` by default, configurable), endpoint-independent mapping is disabled, and connection idle timeouts and operation timeouts are set explicitly.

## Usage

Add **module.router_nat.tf** to your code:-

```terraform
module "router_nat" {
  source  = "jameswoolfenden/router-nat/gcp"
  name    = "example-router"
  region  = "europe-west2"
  network = google_compute_network.private.id

  subnetworks = [
    {
      name                    = google_compute_subnetwork.nodes.self_link
      source_ip_ranges_to_nat = ["PRIMARY_IP_RANGE"]
    }
  ]
}
```

See [example/examplea](example/examplea) for a complete working example.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [google_compute_address.nat](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_router.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router) | resource |
| [google_compute_router_nat.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_description"></a> [description](#input\_description) | Human-readable description of the Cloud Router | `string` | `"Cloud Router for Cloud NAT egress"` | no |
| <a name="input_idle_timeouts"></a> [idle\_timeouts](#input\_idle\_timeouts) | NAT connection idle timeouts in seconds, set explicitly rather than relying on provider defaults | <pre>object({<br/>    udp             = optional(number, 30)<br/>    icmp            = optional(number, 30)<br/>    tcp_established = optional(number, 1200)<br/>    tcp_transitory  = optional(number, 30)<br/>    tcp_time_wait   = optional(number, 120)<br/>  })</pre> | `{}` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels to apply to the static NAT addresses, for cost allocation and ownership tracking | `map(string)` | `{}` | no |
| <a name="input_log_filter"></a> [log\_filter](#input\_log\_filter) | Which NAT events are logged: ERRORS\_ONLY, TRANSLATIONS\_ONLY or ALL. Logging itself is always enabled | `string` | `"ERRORS_ONLY"` | no |
| <a name="input_min_ports_per_vm"></a> [min\_ports\_per\_vm](#input\_min\_ports\_per\_vm) | Minimum number of NAT ports allocated to each VM | `number` | `64` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the Cloud Router; also used as the prefix for the NAT and its static addresses | `string` | n/a | yes |
| <a name="input_nat_ip_allocate_option"></a> [nat\_ip\_allocate\_option](#input\_nat\_ip\_allocate\_option) | How NAT egress IPs are allocated: MANUAL\_ONLY (static google\_compute\_address resources created by this module, allowlistable) or AUTO\_ONLY (Google-allocated, ephemeral) | `string` | `"MANUAL_ONLY"` | no |
| <a name="input_nat_ip_suffixes"></a> [nat\_ip\_suffixes](#input\_nat\_ip\_suffixes) | Suffixes of the static external addresses to reserve when nat\_ip\_allocate\_option is MANUAL\_ONLY; one address named {name}-nat-{suffix} per entry | `set(string)` | <pre>[<br/>  "a"<br/>]</pre> | no |
| <a name="input_nat_name"></a> [nat\_name](#input\_nat\_name) | Name of the Cloud NAT gateway; defaults to {name}-nat | `string` | `null` | no |
| <a name="input_network"></a> [network](#input\_network) | Self link or ID of the VPC network the router is attached to | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region to deploy the Cloud Router and NAT in | `string` | `"europe-west2"` | no |
| <a name="input_subnetworks"></a> [subnetworks](#input\_subnetworks) | Subnetworks (self link or name) to NAT, with the ranges of each to translate. NAT is scoped to exactly this list | <pre>list(object({<br/>    name                     = string<br/>    source_ip_ranges_to_nat  = optional(list(string), ["ALL_IP_RANGES"])<br/>    secondary_ip_range_names = optional(list(string))<br/>  }))</pre> | n/a | yes |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Terraform operation timeouts applied to the router, NAT and addresses | <pre>object({<br/>    create = optional(string, "20m")<br/>    update = optional(string, "20m")<br/>    delete = optional(string, "20m")<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_nat_id"></a> [nat\_id](#output\_nat\_id) | ID of the Cloud NAT gateway |
| <a name="output_nat_ip_addresses"></a> [nat\_ip\_addresses](#output\_nat\_ip\_addresses) | Static external egress IP addresses keyed by suffix (empty when nat\_ip\_allocate\_option is AUTO\_ONLY) |
| <a name="output_nat_name"></a> [nat\_name](#output\_nat\_name) | Name of the Cloud NAT gateway |
| <a name="output_router_id"></a> [router\_id](#output\_router\_id) | ID of the Cloud Router |
| <a name="output_router_name"></a> [router\_name](#output\_router\_name) | Name of the Cloud Router |
| <a name="output_router_self_link"></a> [router\_self\_link](#output\_router\_self\_link) | Self link of the Cloud Router |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Role and Permissions

<!-- BEGINNING OF PRE-COMMIT-PIKE DOCS HOOK -->
The Terraform resource required is:

```golang
# apply role
resource "google_project_iam_custom_role" "terraform_pike" {
  project     = "pike-477416"
  role_id     = "terraform_pike"
  title       = "terraform_pike"
  description = "A user with least privileges"
  permissions = [
    "compute.addresses.create",
    "compute.addresses.createInternal",
    "compute.addresses.delete",
    "compute.addresses.deleteInternal",
    "compute.addresses.get",
    "compute.addresses.setLabels",
    "compute.networks.use",
    "compute.routers.create",
    "compute.routers.delete",
    "compute.routers.get",
    "compute.routers.update",
    "compute.subnetworks.use"
  ]
}

# plan role
resource "google_project_iam_custom_role" "terraform_pike_plan" {
  project     = "pike-477416"
  role_id     = "terraform_pike_plan"
  title       = "terraform_pike_plan"
  description = "A user with least privileges"
  permissions = [
    "compute.addresses.get",
    "compute.routers.get"
  ]
}


```
<!-- END OF PRE-COMMIT-PIKE DOCS HOOK -->

## Help

**Got a question?**

File a GitHub [issue](https://github.com/jameswoolfenden/terraform-gcp-router-nat/issues).

## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/jameswoolfenden/terraform-gcp-router-nat/issues) to report any bugs or file feature requests.

## Copyrights

Copyright © 2026 James Woolfenden

## License

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

See [LICENSE](LICENSE) for full details.

Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements. See the NOTICE file
distributed with this work for additional information
regarding copyright ownership. The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at

<https://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied. See the License for the
specific language governing permissions and limitations
under the License.

### Contributors

[![James Woolfenden][jameswoolfenden_avatar]][jameswoolfenden_homepage]<br/>[James Woolfenden][jameswoolfenden_homepage]

[jameswoolfenden_homepage]: https://github.com/jameswoolfenden
[jameswoolfenden_avatar]: https://github.com/jameswoolfenden.png?size=150
