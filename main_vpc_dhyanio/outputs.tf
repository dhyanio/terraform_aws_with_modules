output "public_subnets" {
  value = "${aws_subnet.public_subnet.*.id}"
}

output "security_group" {
  value = "${aws_security_group.test_sg.id}"
}

output "vpc_id" {
  value = "${aws_vpc.main_vpc_dhyanio.id}"
}

output "subnet_one" {
  value = "${element(aws_subnet.public_subnet.*.id, 1 )}"
}

output "subnet_two" {
  value = "${element(aws_subnet.public_subnet.*.id, 2 )}"
}

output "private_subnet_one" {
  value = "${element(aws_subnet.private_subnet.*.id, 1 )}"
}

output "private_subnet_one" {
  value = "${element(aws_subnet.private_subnet.*.id, 2 )}"
}
