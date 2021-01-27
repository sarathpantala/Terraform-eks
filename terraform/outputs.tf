output "kubeconfig" {
  value = "${module.eks.kubeconfig}"
}

output "config-map-aws-auth" {
  value = "${module.eks.config_map_aws_auth}"
}

output "worker_iam_role_name" {
  value = "${module.eks.worker_iam_role_name}"
}

output "worker_iam_role_arn" {
  value = "${module.eks.worker_iam_role_arn}"
}

output "workers_asg_arns" {
  value = "${module.eks.worker_iam_role_name}"
}

output "workers_asg_names" {
  value = "${module.eks.worker_iam_role_name}"
}

output "workers_security_group_id" {
  value = "${module.eks.worker_security_group_id}"
}

output "web-alb_security_group_id" {
  value = "${aws_security_group.web-alb.id}"
}

output "image-processor-alb_security_group_id" {
  value = "${aws_security_group.image-processor-alb.id}"
}