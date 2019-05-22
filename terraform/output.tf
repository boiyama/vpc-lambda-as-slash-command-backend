output "api_url" {
  value = "${aws_api_gateway_stage.slash_commands.invoke_url}"
}

output "nat_ips" {
  value = "${aws_eip.nat.*.public_ip}"
}
