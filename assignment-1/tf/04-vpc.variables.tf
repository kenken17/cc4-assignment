variable "presentation_subnet_cidr" {
  default = [
    "10.0.10.0/24",
    "10.0.20.0/24"
  ]
}

variable "application_subnet_cidr" {
  default = [
    "10.0.30.0/24",
    "10.0.40.0/24"
  ]
}

variable "data_subnet_cidr" {
  default = [
    "10.0.50.0/24",
    "10.0.60.0/24"
  ]
}

variable "subnet_az" {
  default = [
    "ap-southeast-1a",
    "ap-southeast-1b"
  ]
}
