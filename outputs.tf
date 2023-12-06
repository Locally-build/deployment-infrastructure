output "ssh_private_key" {
  value     = tls_private_key.mac.private_key_pem
  sensitive = true
}

output "host_instance_name" {
  value = [for host in aws_ec2_host.mac : host.instance_type]
}

output "host_id" {
  value = [for host in aws_ec2_host.mac : host.id]
}

output "instance_public_ip" {
  value = [for instance in aws_instance.mac : instance.public_ip]
}

output "parallels-desktop_host" {
  value = [for host in parallels-desktop_deploy.deploy : "${host.api.host}:${host.api.port}"]
}

output "parallels-desktop_api_key" {
  value = [for keys in parallels-desktop_auth.security : keys.api_key[0].api_key]
  sensitive = true
}