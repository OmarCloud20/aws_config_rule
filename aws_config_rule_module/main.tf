terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}


#==============================================================================
# AWS Config Rule
#==============================================================================
resource "aws_config_config_rule" "kms_key_deletion" {
  name                        = "kms-cmk-not-scheduled-for-deletion"
  maximum_execution_frequency = var.evaluation_period

  source {
    owner             = "AWS"
    source_identifier = "KMS_CMK_NOT_SCHEDULED_FOR_DELETION"
  }
}
#==============================================================================
# AWS Config Remediation Configuration
#==============================================================================
resource "aws_config_remediation_configuration" "kms_key_deletion" {
  config_rule_name = aws_config_config_rule.kms_key_deletion.name

  target_type                = "SSM_DOCUMENT"
  target_id                  = "AWS-PublishSNSNotification"
  automatic                  = true
  maximum_automatic_attempts = 5
  retry_attempt_seconds      = 60

  parameter {
    name         = "TopicArn"
    static_value = aws_sns_topic.main.arn
  }

  parameter {
    name         = "AutomationAssumeRole"
    static_value = aws_iam_role.main.arn
  }

  parameter {
    name         = "Message"
    static_value = var.parameter_message
  }

}
#==============================================================================
# AWS SNS Topic
#==============================================================================
resource "aws_sns_topic" "main" {
  name = var.sns_topic_name
}

# Subscribe to SNS Topic email address
resource "aws_sns_topic_subscription" "main" {
  topic_arn = aws_sns_topic.main.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.main.arn
}
#==============================================================================
# IAM Role for AWS Config rule to publish to SNS Topic
#==============================================================================
resource "aws_iam_role" "main" {
  name        = "${var.iam_role_name}_${random_string.random.result}"
  description = "IAM Role for AWS Config to publish to SNS Topic"

  assume_role_policy = file("${path.module}/source/policies/aws_config_iam_role.json")
}

resource "aws_iam_policy" "main" {
  name        = "${var.iam_role_name}_${random_string.random.result}_policy"
  description = "IAM Policy for AWS Config IAM role to publish to SNS Topic"

  policy = templatefile("${path.module}/source/policies/aws_config_policy.json", {
    sns_topic_arn = aws_sns_topic.main.arn
  })
}

resource "aws_iam_role_policy_attachment" "main" {
  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.main.arn
}
#==============================================================================
# Lambda Function to Slack Channel
#==============================================================================
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/source/function/lambda_function.py"
  output_path = "${path.module}/source/artifacts/lambda.zip"
}

resource "aws_lambda_function" "main" {
  function_name    = "${var.lambda_function_name}_${random_string.random.result}"
  description      = "Lambda function to send AWS Config messages to Slack channel"
  handler          = "lambda_function.lambda_handler"
  role             = aws_iam_role.lambda.arn
  runtime          = "python3.7"
  memory_size      = "128"
  timeout          = "30"
  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256
}
resource "aws_iam_role" "lambda" {
  name        = "${var.lambda_iam_role_name}_${random_string.random.result}"
  description = var.iam_role_description

  assume_role_policy = file("${path.module}/source/policies/aws_lambda_iam_role.json")
}

# IAM Policy for AWS Lambda IAM role to get Secrets Mansger secret to send AWS Config messages to Slack channel
resource "aws_iam_policy" "lambda" {
  name        = "${var.lambda_iam_role_name}_GetSecretValue_${random_string.random.result}_policy"
  description = "IAM Policy for AWS Lambda IAM role to get Secrets Mansger secret to send AWS Config messages to Slack channel"

  policy = file("${path.module}/source/policies/aws_lambda_policy.json")
}

# Attach AWSLambdaBasicExecutionRole managed policy to the IAM role
resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Attach IAM policy to the Lambda IAM role to get Secrets Mansger secret to send AWS Config messages to Slack channel
resource "aws_iam_role_policy_attachment" "lambda2" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
}
# Manged CloudWatch Logs Group retention policy for the Lambda function
resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/lambda/${aws_lambda_function.main.function_name}"
  retention_in_days = 14
}

resource "aws_lambda_permission" "main" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.main.arn
}
