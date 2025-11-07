output "bucket_artifacts" {
  value       = aws_s3_bucket.artifacts.bucket
  description = "Numele bucket-ului S3 pentru artefacte"
}

output "keypair_name" {
  value       = aws_key_pair.monitor_key.key_name
  description = "Numele key pair-ului creat"
}

output "instance_id" {
  value       = aws_instance.monitor_vm.id
  description = "ID-ul instanței EC2 simulate"
}
