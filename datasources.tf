data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "mac" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["*mac*"]
  }

  filter {
    name   = "architecture"
    values = ["arm*"]
  }
}
