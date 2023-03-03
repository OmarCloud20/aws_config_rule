#==============================================================================
# AWS Region and Default Tags
#=============================================================================
variable "region" {
  type    = string
  default = "us-east-1"
}
variable "tags" {
  type = map(string)
  default = {
    "Name"          = "aws_config_module",
    "t_environment" = "dev",
    "t_dcl"         = "2",
    "t_AppID"       = "SVC00000",
  }
}
#==============================================================================
# AWS Config Remediation Configuration Variable
#==============================================================================
variable "parameter_message" {
  description = "This is the message sent to the SNS Topic"
  type        = string
  default     = "WARNING: A KMS CMK is scheduled for deletion"
}
variable "evaluation_period" {
  description = "This is the evaluation period for the AWS Config Rule"
  type        = string
  default     = "TwentyFour_Hours"
}
#==============================================================================
# SNS Variables
#==============================================================================
variable "sns_topic_name" {
  description = "This is the name of the SNS Topic"
  type        = string
  default     = "aws_config_sns_topic"
}
#==============================================================================
# IAM Role Variables
#==============================================================================
variable "iam_role_name" {
  description = "This is the name of the IAM Role"
  type        = string
  default     = "aws_config_role"
}
variable "iam_role_description" {
  description = "This is the description of the IAM Role"
  type        = string
  default     = "This is the IAM Role for AWS Config to publish to SNS Topic"
}
#==============================================================================
# Random String Generator
#==============================================================================
resource "random_string" "random" {
  length  = 6
  upper   = false
  lower   = false
  special = false
}
#==============================================================================
# AWS Lambda Function
#==============================================================================
variable "lambda_function_name" {
  description = "This is the name of the Lambda Function"
  type        = string
  default     = "ConfigRemediation"
}
variable "lambda_iam_role_name" {
  description = "This is the name of the IAM Role for the Lambda Function"
  type        = string
  default     = "ConfigRemediationRole"
}