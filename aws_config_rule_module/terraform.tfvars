#==============================================================================
# AWS Config Remediation Configuration Variable
#==============================================================================
parameter_message  = "WARNING: A KMS CMK is scheduled for deletion"
evaluation_period  = "TwentyFour_Hours" # Options are: One_Hour, Three_Hours, Six_Hours, Twelve_Hours, TwentyFour_Hours
region             = "us-east-1"
#==============================================================================