resource "aws_ssm_parameter" "cloudwatch_logging_config" {
  name  = "AmazonCloudWatch-ssm-cloudwatch-logging-param"
  type  = "String"
  value = file("json/ssm-cloudwatch-logging-param.json")
}

resource "aws_ssm_document" "cloudwatch_logging_document" {
  name          = "Logging-SetupCloudWatchAgent"
  document_type = "Command"
  content       = <<DOC
  {
    "schemaVersion": "2.2",
    "description": "Install CW agent and set logging configuration from SSM Parameter Store.",
    "parameters": {
      "CWparameter": {
        "type": "String",
        "description": "CloudWatch agent setting name in SSM Parameter Store",
        "default": "AmazonCloudWatch-ssm-cloudwatch-logging-param"
      }
    },
    "mainSteps": [
      {
        "action": "aws:runDocument",
        "name": "installCWAgent",
        "inputs": {
          "documentType": "SSMDocument",
          "documentPath": "AWS-ConfigureAWSPackage",
          "documentParameters": "{\"action\":\"Install\",\"name\" : \"AmazonCloudWatchAgent\"}"
        }
      },
      {
        "action": "aws:runDocument",
        "name": "setCWAgentConfig",
        "inputs": {
          "documentType": "SSMDocument",
          "documentPath": "AmazonCloudWatch-ManageAgent",
          "documentParameters": "{\"action\":\"configure\",\"mode\" : \"ec2\", \"optionalConfigurationSource\" : \"ssm\", \"optionalConfigurationLocation\" : \"{{CWparameter}}\", \"optionalRestart\" : \"yes\"}"
        }
      }
    ]
  }
DOC
}

resource "aws_ssm_association" "cloudwatch_logging_association" {
  name             = aws_ssm_document.cloudwatch_logging_document.name
  association_name = aws_ssm_document.cloudwatch_logging_document.name
  parameters = {
    CWparameter = "AmazonCloudWatch-ssm-cloudwatch-logging-param"
  }

  schedule_expression = "cron(0 */30 * * * ? *)"
  targets {
    key    = "InstanceIds"
    values = ["*"]
  }
}

