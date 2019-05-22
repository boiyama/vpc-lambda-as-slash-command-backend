# Create security group for Lambda
resource "aws_security_group" "lambda" {
  vpc_id      = "${aws_vpc.main.id}"
  name        = "lambda"
  description = "${var.namespace} VPC security group for Lambda"

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["${var.cidr_block}"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.namespace}-sg-lambda"
  }
}

# Create IAM role for Lambda
resource "aws_iam_role" "lambda" {
  name               = "${title(var.namespace)}RoleForLambda"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_lambda.json}"
}

data "aws_iam_policy_document" "assume_role_lambda" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "vpc_read_only_access" {
  role       = "${aws_iam_role.lambda.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = "${aws_iam_role.lambda.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_sqs_queue" {
  role       = "${aws_iam_role.lambda.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

// Create Lambda function
data "archive_file" "slash_commands" {
  type        = "zip"
  source_dir  = "../dist"
  output_path = "code.zip"
}

resource "aws_lambda_function" "slash_commands" {
  filename         = "${data.archive_file.slash_commands.output_path}"
  source_code_hash = "${data.archive_file.slash_commands.output_base64sha256}"
  function_name    = "${title(var.namespace)}SlashCommands"
  handler          = "main.handler"
  role             = "${aws_iam_role.lambda.arn}"
  runtime          = "nodejs10.x"

  vpc_config {
    security_group_ids = ["${aws_security_group.lambda.id}"]
    subnet_ids         = ["${aws_subnet.private.*.id}"]
  }
}

resource "aws_lambda_event_source_mapping" "sqs" {
  event_source_arn = "${aws_sqs_queue.slash_commands.arn}"
  function_name    = "${aws_lambda_function.slash_commands.arn}"
}
