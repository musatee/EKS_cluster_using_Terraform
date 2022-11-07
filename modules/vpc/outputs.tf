output "vpc" {
  value = aws_vpc.webapp_vpc.id
}
output "vpc_cidr" {
  value = aws_vpc.webapp_vpc.cidr_block
}
output "public_sub1" {
  value = aws_subnet.webapp_sub["public_sub1"]
}

output "public_sub2" {
  value = aws_subnet.webapp_sub["public_sub2"]
}

output "public_sub3" {
  value = aws_subnet.webapp_sub["public_sub3"]
}

output "common_tags" {
  value = {
    Created_By  = local.common_tags["Created_By"]
    Environment = local.common_tags["Environment"]
  }
}
