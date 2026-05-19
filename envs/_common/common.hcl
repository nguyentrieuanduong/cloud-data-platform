locals {
  org          = "vpbs"
  department   = "eda"
  project      = "cloud-data-platform"
  owner        = "eda-platform"
  cost_center  = "eda"
  region       = "ap-southeast-1"
  region_short = "apse1"

  proxy_host = "proxy.internal.example.com"
  proxy_port = 8080

  repo_server_host = "repo.internal.example.com"
  repo_server_port = 443

  proxy_cidr_blocks = [
    "10.200.10.10/32",
  ]

  repo_server_cidr_blocks = [
    "10.200.20.10/32",
  ]

  on_prem_cidrs = [
    "10.100.0.0/16",
  ]

  workload_egress_ports = [
    443,
    5432,
    3306,
    1433,
    1521,
    9092,
  ]
}
