variable "vpc_cidr" {
  type    = string
  default = "192.168.0.0/16"
}

variable "subnets" {
  type = map(any)
  default = {
    "public_sub1" = {
      "newbit" = 8
      "netnum" = 10
      "az"     = "ap-southeast-1a"
    }
    "public_sub2" = {
      "newbit" = 8
      "netnum" = 20
      "az"     = "ap-southeast-1b"
    }
    "public_sub3" = {
      "newbit" = 8
      "netnum" = 30
      "az"     = "ap-southeast-1c"
    }
  }
}