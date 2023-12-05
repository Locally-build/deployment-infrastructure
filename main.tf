resource "aws_key_pair" "generated_key" {
  key_name   = "${var.host_base_name}-terraform"
  public_key = tls_private_key.mac.public_key_openssh
}

resource "aws_ec2_host" "mac" {
  count = var.host_count

  instance_type     = var.use_intel ? "mac1.metal" : var.use_m2_pro ? "mac2-m2pro.metal" : "mac2.metal"
  availability_zone = data.aws_availability_zones.available.names[var.aws_availability_zone_index]
  host_recovery     = "off"
  auto_placement    = "on"
  tags = {
    Name = "${substr(var.aws_region, 0, 2)}-${var.host_base_name}.${count.index}"
  }
}

module "vpc" {
  source                  = "terraform-aws-modules/vpc/aws"
  version                 = "4.0.1"
  name                    = "${substr(var.aws_region, 0, 2)}-${var.host_base_name}-vpc"
  azs                     = [data.aws_availability_zones.available.names[var.aws_availability_zone_index]]
  cidr                    = var.vpc_cidr
  private_subnets         = var.pvc_private_subnets
  public_subnets          = var.vpc_public_subnets
  enable_dns_hostnames    = true
  enable_dns_support      = true
  map_public_ip_on_launch = true
}

resource "aws_security_group" "ssh" {
  name        = "${substr(var.aws_region, 0, 2)}_${var.host_base_name}-ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Parallels Desktop API"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "VNC from VPC"
    from_port   = 5900
    to_port     = 5900
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "mac" {
  count = var.host_count

  ami           = var.aws_ami_id == "" ? data.aws_ami.mac.id : var.aws_ami_id
  instance_type = aws_ec2_host.mac[count.index].instance_type
  key_name      = aws_key_pair.generated_key.key_name

  availability_zone = data.aws_availability_zones.available.names[var.aws_availability_zone_index]
  host_id           = aws_ec2_host.mac[count.index].id

  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.ssh.id]

  root_block_device {
    volume_size           = var.host_disk_size
    delete_on_termination = true
    encrypted             = true
    iops                  = var.host_disk_iops
    volume_type           = var.host_disk_type
  }

  tags = {
    Name = "${substr(var.aws_region, 0, 2)}-${var.host_base_name}.${count.index}"
  }
}

resource "time_sleep" "wait_for_instance" {
  depends_on = [aws_instance.mac]

  create_duration = "240s"
}

// This block will deploy the parallels-desktop
resource "parallels-desktop_deploy" "deploy" {
  count = var.host_count

  api_config {
    port      = "8080"
    log_level = "debug"
    mode      = "api"
  }

  dynamic "orchestrator_registration" {
    for_each = var.orchestrator.host == "" ? [] : [1]
    content {
      tags = [
        "${substr(var.aws_region, 0, 2)}",
        "${var.host_base_name}.${count.index}"
      ]
      description = "${substr(var.aws_region, 0, 2)}-${var.host_base_name}.${count.index}"

      orchestrator {
        schema = var.orchestrator.schema
        host   = var.orchestrator.host
        port   = var.orchestrator.port
        dynamic "authentication" {
          for_each = var.orchestrator.username == "" && var.orchestrator.api_key == "" ? [] : [1]
          content {
            username = var.orchestrator.username
            password = var.orchestrator.password
            api_key  = var.orchestrator.api_key
          }
        }
      }
    }
  }

  ssh_connection {
    user        = "ec2-user"
    private_key = tls_private_key.mac.private_key_pem
    host        = aws_instance.mac[count.index].public_ip
    host_port   = "22"
  }

  depends_on = [
    time_sleep.wait_for_instance
  ]
}
