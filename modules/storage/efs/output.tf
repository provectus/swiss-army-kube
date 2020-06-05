output "filesystem" {
  value = aws_efs_file_system.this
}

output "mount_target_map" {
  value = aws_efs_mount_target.this
}
