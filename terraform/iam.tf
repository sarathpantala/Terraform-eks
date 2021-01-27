data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["${module.eks.worker_iam_role_arn}"]
    }
  }
}

data "template_file" "route53-policy" {
  template = "${file("${path.module}/iam/route53-policy.json")}"

  vars = {
    route53_zone_id        = "${var.route53_zone_id}"
  }
}

resource "aws_iam_role" "route53" {
  name               = "${var.cluster_name}-route53-role"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

resource "aws_iam_policy" "route53" {
  name        = "${var.cluster_name}-route53-policy"
  policy      = "${data.template_file.route53-policy.rendered}"
}

resource "aws_iam_policy_attachment" "route53" {
  name       = "${var.cluster_name}-app-attachment"
  roles      = ["${aws_iam_role.route53.name}"]
  policy_arn = "${aws_iam_policy.route53.arn}"
}

data "aws_iam_policy_document" "autoscaling_policy" {
  statement {
    sid = "1"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
    ]

    resources = [
      "*",
    ]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${var.cluster_name}"

      values = [
        "owned",
      ]
    }
  }
}

resource "aws_iam_role" "autoscaling" {
  name               = "${var.cluster_name}-autoscaling-role"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

resource "aws_iam_policy" "autoscaling" {
  name        = "${var.cluster_name}-autoscaling-policy"
  description = "Managed by Terraform. Access to autoscale worker nodes."
  policy      = "${data.aws_iam_policy_document.autoscaling_policy.json}"
}

resource "aws_iam_policy_attachment" "autoscaling" {
  name       = "${var.cluster_name}-autoscaling-attachment"
  roles      = ["${aws_iam_role.autoscaling.name}"]
  policy_arn = "${aws_iam_policy.autoscaling.arn}"
}

data "template_file" "alb-ingress-policy" {
  template = "${file("${path.module}/iam/alb-ingress-policy.json")}"
}

resource "aws_iam_role" "alb-ingress-role" {
  name               = "${var.cluster_name}-alb-ingress-role"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

resource "aws_iam_policy" "alb-ingress-policy" {
  name        = "${var.cluster_name}-alb-ingress-role-policy"
  policy      = "${data.template_file.alb-ingress-policy.rendered}"
}

resource "aws_iam_policy_attachment" "alb-ingress-role" {
  name       = "${var.cluster_name}-alb-ingress-policy-attachment"
  roles      = ["${aws_iam_role.alb-ingress-role.name}"]
  policy_arn = "${aws_iam_policy.alb-ingress-policy.arn}"
}

data "template_file" "logstash-policy" {
  template = "${file("${path.module}/iam/logstash-policy.json")}"
  vars = {
    web_kinesis_stream_arn        = "${var.web_kinesis_stream_arn}"
  }
}

resource "aws_iam_role" "logstash-role" {
  name               = "${var.cluster_name}-logstash-role"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

resource "aws_iam_policy" "logstash-policy" {
  name        = "${var.cluster_name}-logstash-role-policy"
  policy      = "${data.template_file.logstash-policy.rendered}"
}

resource "aws_iam_policy_attachment" "logstash-role" {
  name       = "${var.cluster_name}-logstash-policy-attachment"
  roles      = ["${aws_iam_role.logstash-role.name}"]
  policy_arn = "${aws_iam_policy.logstash-policy.arn}"
}

resource "aws_iam_policy" "logstash-additional-policy" {
  count       = "${length(var.log_stream_list) > 0 ? 1 : 0 }"
  name        = "${var.cluster_name}-logstash-role-additional-policy"
  policy      = "${data.aws_iam_policy_document.logstash-consumer-policy.json}"
}

resource "aws_iam_policy_attachment" "logstash-role-additonal" {
  count       = "${length(var.log_stream_list) > 0 ? 1 : 0 }"
  name       = "${var.cluster_name}-logstash-policy-addtional-attachment"
  roles      = ["${aws_iam_role.logstash-role.name}"]
  policy_arn = "${aws_iam_policy.logstash-additional-policy.arn}"
}

data "template_file" "backup-logs-policy" {
  template = "${file("${path.module}/iam/backup-logs-policy.json")}"
  vars = {
    backup_logs_s3_bucket        = "${var.backup_logs_s3_bucket}"
  }
}

resource "aws_iam_role" "backup-logs-role" {
  name               = "${var.cluster_name}-backup-logs-role"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

resource "aws_iam_policy" "backup-logs-policy" {
  name        = "${var.cluster_name}-backup-logs-role-policy"
  policy      = "${data.template_file.backup-logs-policy.rendered}"
}

resource "aws_iam_policy_attachment" "backup-logs-role" {
  name       = "${var.cluster_name}-backup-logs-policy-attachment"
  roles      = ["${aws_iam_role.backup-logs-role.name}"]
  policy_arn = "${aws_iam_policy.backup-logs-policy.arn}"
}

data "template_file" "additional_policy" {
  template = "${file("${path.module}/iam/additional-policy.json")}"
  vars = {
    backup_logs_s3_bucket        = "${var.backup_logs_s3_bucket}"
  }
}

resource "aws_iam_policy" "additional_policy" {
  name        = "${var.cluster_name}-additional_policy"
  policy      = "${data.template_file.additional_policy.rendered}"
}

data "template_file" "image-processor-policy" {
  template = "${file("${path.module}/iam/image-processor-policy.json")}"
  vars = {
    image_processor_s3_bucket        = "${var.image_processor_s3_bucket}"
  }
}

resource "aws_iam_role" "image-processor-role" {
  name               = "${var.cluster_name}-image-processor-role"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

resource "aws_iam_policy" "image-processor-policy" {
  name        = "${var.cluster_name}-image-processor-role-policy"
  policy      = "${data.template_file.image-processor-policy.rendered}"
}

resource "aws_iam_policy_attachment" "image-processor-role" {
  name       = "${var.cluster_name}-image-processor-policy-attachment"
  roles      = ["${aws_iam_role.image-processor-role.name}"]
  policy_arn = "${aws_iam_policy.image-processor-policy.arn}"
}

data "aws_kinesis_stream" "logs-stream" {
  count = "${length(var.log_stream_list)}"
  name = "${var.log_stream_list[count.index]}"
}

data "aws_dynamodb_table" "logs-stream-dynamodb" {
  count = "${length(var.log_stream_dynamodb_list)}"
  name = "${var.log_stream_dynamodb_list[count.index]}"
}

data "aws_iam_policy_document" "logstash-consumer-policy" {
  count = "${length(var.log_stream_list) > 0 ? 1 : 0 }"
  statement {
    sid = "1"
    effect = "Allow"
    actions = [
      "kinesis:Describe*",
      "kinesis:Get*",
      "kinesis:ListShards",
      "kinesis:ListStream*",
      "kinesis:Put*"
    ]

    resources = [ "${data.aws_kinesis_stream.logs-stream.*.arn}" ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kinesis:ListStreams"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricData",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "dynamodb:*"
    ]

    resources = [ "${data.aws_dynamodb_table.logs-stream-dynamodb.*.arn}" ] 
  
  }
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:CreateTable"
    ]

    resources = [ "*" ]
  }
  statement {
    effect = "Deny"
    actions = [
      "dynamodb:DeleteBackup",
      "dynamodb:DeleteTable",
      "dynamodb:DeleteTableReplica"
    ]

    resources = [
      "*"
    ]
  }

}

resource "aws_iam_role" "logstash-consumer-role" {
  count = "${length(var.log_stream_list) > 0 ? 1 : 0 }"
  name               = "${var.cluster_name}-logstash-consumer-role"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

resource "aws_iam_policy" "logstash-consumer-policy" {
  count = "${length(var.log_stream_list) > 0 ? 1 : 0 }"
  name        = "${var.cluster_name}-logstash-consumer-role-policy"
  policy      = "${data.aws_iam_policy_document.logstash-consumer-policy.json}"
}

resource "aws_iam_policy_attachment" "logstash-consumer-role" {
  count = "${length(var.log_stream_list) > 0 ? 1 : 0 }"
  name       = "${var.cluster_name}-logstash-consumer-policy-attachment"
  roles      = [ "${aws_iam_role.logstash-consumer-role.name}" ]
  policy_arn = "${aws_iam_policy.logstash-consumer-policy.arn}"
}

data "template_file" "targetgroupbinding-policy" {
  count = "${var.sg_alb_mapp > 0 ? 1 : 0 }"
  template = "${file("${path.module}/iam/targetgroupbinding-policy.json")}"
}

resource "aws_iam_role" "targetgroupbinding-role" {
  count = "${var.sg_alb_mapp > 0 ? 1 : 0 }"
  name               = "${var.cluster_name}-targetgroupbinding-role"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

resource "aws_iam_policy" "targetgroupbinding-policy" {
  count = "${var.sg_alb_mapp > 0 ? 1 : 0 }"
  name        = "${var.cluster_name}-targetgroupbinding-role-policy"
  policy      = "${data.template_file.targetgroupbinding-policy.rendered}"
}

resource "aws_iam_policy_attachment" "targetgroupbinding-policy-attachment" {
  count = "${var.sg_alb_mapp > 0 ? 1 : 0 }"
  name       = "${var.cluster_name}-targetgroupbinding-policy-attachment"
  roles      = ["${aws_iam_role.targetgroupbinding-role.name}"]
  policy_arn = "${aws_iam_policy.targetgroupbinding-policy.arn}"
}
