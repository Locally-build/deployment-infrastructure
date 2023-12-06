resource "tls_private_key" "mac" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_private_key" "database" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "random_password" "api_key" {
  length           = 32
  special          = false
  override_special = "_%@"
}

resource "random_password" "admin_user" {
  length           = 8
  special          = false
  override_special = "_%@"
}

resource "parallels-desktop_auth" "security" {
  count = var.host_count
  host = "${parallels-desktop_deploy.deploy[count.index].api.host}:${parallels-desktop_deploy.deploy[count.index].api.port}"

  api_key {
    name   = "Terraform"
    key    = "TerraformOps"
    secret = random_password.api_key.result
  }

  claim {
    name = "GITHUB_ACTIONS_RUNNER"
  }

  role {
    name = "ADMIN"
  }

  user {
    name     = "Admin User"
    username = "admin"
    email    = "admin@example.com"
    password = random_password.admin_user.result
    roles = [
      {
        name = "ADMIN"
      }
    ]
    claims = [
      {
        name = "GITHUB_ACTIONS_RUNNER"
      }
    ]
  }

  depends_on = [
    parallels-desktop_deploy.deploy
  ]
}