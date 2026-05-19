locals {
  environment = "uat"
  account_id  = "111111111111"
  data_class  = "internal"

  vpc_cidr             = "10.10.0.0/16"
  public_subnet_cidrs  = ["10.10.0.0/24"]
  private_subnet_cidrs = ["10.10.10.0/24", "10.10.11.0/24"]

  transit_gateway_id = "tgw-uat-placeholder"
  vgw_id             = null

  permissions_boundary_arn = null
}
