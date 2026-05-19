locals {
  environment = "prod"
  account_id  = "222222222222"
  data_class  = "confidential"

  vpc_cidr             = "10.20.0.0/16"
  public_subnet_cidrs  = ["10.20.0.0/24"]
  private_subnet_cidrs = ["10.20.10.0/24", "10.20.11.0/24"]

  transit_gateway_id = "tgw-prod-placeholder"
  vgw_id             = null

  permissions_boundary_arn = "arn:aws:iam::222222222222:policy/vpbs-eda-prod-permissions-boundary"
}
