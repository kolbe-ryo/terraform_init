output "public_ip" {
  value = module.wordpress.public_ip
}
output "rds_endpoint" {
  value = module.wordpress.rds_endpoint
}
output "rds_password" {
  value     = module.wordpress.rds_password
  sensitive = true
}