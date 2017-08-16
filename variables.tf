
variable "region" {
    type = "string"
    default = "eu-west-1"
}
variable "availability_zones" {
    type = "list"
    default = ["a", "b", "c"]
}
/*You will also need CIDR:*/

variable "private_cidr" {
    type = "string"
    default = "10.0.0.0/16"
}
variable "environment" {
  default = "test"
}
variable "name" {
  default = "test"
}
variable "private_subnets_cidr" {
	description = "CIDR for private subnets"
	default = "10.0.30.0/22,10.0.40.0/22,10.0.50.0/22"
}
variable "public_subnets_cidr" {
	description = "CIDR for private subnets"
	default = "10.0.0.0/22,10.0.4.0/22,10.0.8.0/22"
}
