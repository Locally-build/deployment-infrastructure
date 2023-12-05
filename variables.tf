variable "aws_access_key" {
  type      = string
  sensitive = true
}

variable "aws_secret_key" {
  type      = string
  sensitive = true
}

variable "aws_region" {
  type = string
}

variable "aws_availability_zone_index" {
  type    = number
  default = 0
}

variable "script_version" {
  type    = string
  default = "1.0.0"
}

variable "aws_ami_id" {
  type    = string
  default = "" # MacOS Ventura
}

variable "host_disk_size" {
  type    = number
  default = 500
}

variable "host_disk_type" {
  type    = string
  default = "gp3"
}

variable "host_disk_iops" {
  type    = number
  default = 7000

}

variable "host_count" {
  type    = number
  default = 1
}

variable "host_base_name" {
  type    = string
  default = "macos"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "pvc_private_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

}

variable "vpc_public_subnets" {
  type    = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "use_intel" {
  type    = bool
  default = false
}

variable "use_m2_pro" {
  type    = bool
  default = false
}

variable "parallels_key" {
  type      = string
  sensitive = true
}

variable "catalog_host" {
  type = string
}

variable "catalog_username" {
  type = string
}

variable "catalog_password" {
  type      = string
  sensitive = true
}

variable "orchestrator" {
  type = object({
    schema   = string
    host     = string
    port     = string
    username = string
    password = string
    api_key  = string
  })

  default = {
    host     = ""
    schema   = ""
    port     = ""
    username = ""
    password = ""
    api_key  = ""
  }
}