resource "parallels-desktop_remote_vm" "cache_linux_builder" {
  count = var.host_count
  host            = "${parallels-desktop_deploy.deploy[count.index].api.host}:${parallels-desktop_deploy.deploy[count.index].api.port}"
  name            = "ubuntu-github-actions-runner-base"
  owner           = "ec2-user"
  catalog_id      = "ubuntu-github-actions-runner"
  version         = "v1"
  host_connection = "host=root:Nmo5c2U1YTZycWc0Ojc4YmZkOWNlZjJmMjU0ZDQ4MjAwNWM2ZTIwYTNlMTM2@parallels.carloslapao.com"
  path            = "/Users/ec2-user/Parallels"

  authenticator {
    api_key = parallels-desktop_auth.security[count.index].api_key[0].api_key
  }

  config {
    start_headless = true
  }

  force_changes = true

  run_after_create = false

  depends_on = [
    parallels-desktop_deploy.deploy
  ]
}

resource "parallels-desktop_remote_vm" "cache_macos_builder" {
    count = var.host_count
  host            = "${parallels-desktop_deploy.deploy[count.index].api.host}:${parallels-desktop_deploy.deploy[count.index].api.port}"
  name            = "macos14-github-actions-runner-base"
  owner           = "ec2-user"
  catalog_id      = "macos-14-github-actions-runner"
  version         = "v1"
  host_connection = "host=${var.catalog_username}:${var.catalog_password}@${var.catalog_host}"
  path            = "/Users/ec2-user/Parallels"

  authenticator {
    api_key = parallels-desktop_auth.security[count.index].api_key[0].api_key
  }


  config {
    start_headless = true
  }

  force_changes = true

  run_after_create = false

  depends_on = [
    parallels-desktop_deploy.deploy
  ]
}