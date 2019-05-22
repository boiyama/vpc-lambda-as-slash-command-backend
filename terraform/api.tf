# Create IAM role for API 
resource "aws_iam_role" "api" {
  name               = "${title(var.namespace)}RoleForAPIGateway"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_api.json}"
}

data "aws_iam_policy_document" "assume_role_api" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "api_push_to_logs" {
  role       = "${aws_iam_role.api.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_iam_role_policy_attachment" "sqs_full_access" {
  role       = "${aws_iam_role.api.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}

# Add IAM role to API account
resource "aws_api_gateway_account" "main" {
  cloudwatch_role_arn = "${aws_iam_role.api.arn}"
}

# Create API
resource "aws_api_gateway_rest_api" "slash_commands" {
  name = "${title(var.namespace)}SlashCommands"
}

resource "aws_api_gateway_method" "slash_commands" {
  rest_api_id   = "${aws_api_gateway_rest_api.slash_commands.id}"
  resource_id   = "${aws_api_gateway_rest_api.slash_commands.root_resource_id}"
  http_method   = "POST"
  authorization = "NONE"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_api_gateway_integration" "slash_commands" {
  rest_api_id             = "${aws_api_gateway_rest_api.slash_commands.id}"
  resource_id             = "${aws_api_gateway_rest_api.slash_commands.root_resource_id}"
  http_method             = "${aws_api_gateway_method.slash_commands.http_method}"
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:sqs:path/${data.aws_caller_identity.current.account_id}/${aws_sqs_queue.slash_commands.name}"
  credentials             = "${aws_iam_role.api.arn}"
  passthrough_behavior    = "NEVER"

  request_templates = {
    "application/x-www-form-urlencoded" = "Action=SendMessage&QueueUrl=$util.urlEncode('${aws_sqs_queue.slash_commands.id}')&MessageBody=$util.urlEncode($input.body)"
  }
}

resource "aws_api_gateway_method_response" "slash_commands" {
  rest_api_id = "${aws_api_gateway_rest_api.slash_commands.id}"
  resource_id = "${aws_api_gateway_rest_api.slash_commands.root_resource_id}"
  http_method = "${aws_api_gateway_method.slash_commands.http_method}"
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "slash_commands" {
  rest_api_id = "${aws_api_gateway_rest_api.slash_commands.id}"
  resource_id = "${aws_api_gateway_rest_api.slash_commands.root_resource_id}"
  http_method = "${aws_api_gateway_method.slash_commands.http_method}"
  status_code = "${aws_api_gateway_method_response.slash_commands.status_code}"

  response_templates = {
    "application/json" = "#stop()"
  }
}

resource "aws_api_gateway_deployment" "slash_commands" {
  depends_on  = ["aws_api_gateway_integration.slash_commands"]
  rest_api_id = "${aws_api_gateway_rest_api.slash_commands.id}"
  stage_name  = "dev"
}

resource "aws_api_gateway_stage" "slash_commands" {
  rest_api_id   = "${aws_api_gateway_rest_api.slash_commands.id}"
  deployment_id = "${aws_api_gateway_deployment.slash_commands.id}"
  stage_name    = "prod"
}

resource "aws_api_gateway_method_settings" "slash_commands" {
  rest_api_id = "${aws_api_gateway_rest_api.slash_commands.id}"
  stage_name  = "${aws_api_gateway_stage.slash_commands.stage_name}"
  method_path = "*/*"

  settings {
    logging_level = "ERROR"
  }
}