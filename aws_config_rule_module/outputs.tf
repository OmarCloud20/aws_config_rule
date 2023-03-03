
#==============================================================================
# SNS Topic
#==============================================================================
output "sns_topic_name" {
  value = aws_sns_topic.main.name
}
#==============================================================================
# IAM Role
#==============================================================================
output "iam_role_name" {
  value = aws_iam_role.main.name
}
#==============================================================================
# AWS Config Rule Name
#==============================================================================
output "aws_config_rule_name" {
  value = aws_config_config_rule.kms_key_deletion.name
}
#==============================================================================
# AWS Lambda Function Name
#==============================================================================
output "lambda_function_name" {
  value = aws_lambda_function.main.function_name
}
#==============================================================================