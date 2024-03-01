variable "presentation-subnet-cidr" {
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

variable "application-subnet-cidr" {
  default = [
    "10.0.3.0/24",
    "10.0.4.0/24"
  ]
}

variable "data-subnet-cidr" {
  default = [
    "10.0.5.0/24",
    "10.0.6.0/24"
  ]
}

variable "subnet-az" {
  default = [
    "ap-southeast-1a",
    "ap-southeast-1b"
  ]
}
