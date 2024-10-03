variable "appstream_app_settings_bucket" {
  description = "Name of bucket containing all the appsettings VHDX files for your appstream users."
  type        = string
}

variable "appstream_app_settings_bucket_prefix" {
  description = "Prefix to all the VHDX files in the bucket."
  type        = string
}

variable "batch_size" {
  description = "How many VHDX files should be processed per trigger."
  type        = string
  default     = 10
}

variable "trigger_schedule" {
  description = "Schedule on which the automation should be executed."
  type        = string
  default     = "cron(30 20 * * ? *)"
}

variable "trigger_timezone" {
  description = "What timezone you are in. This is used for the trigger_schedule."
  type        = string
  default     = "GMT+01:00"
}

variable "ec2_subnet" {
  description = "ID of subnet in which the Windows Host should be placed."
  type        = string
}

variable "notification_endpoints" {
  description = "Set of emailaddresses to notify on failure."
  type        = set(string)
}

variable "ec2_instance_type" {
  default     = "t3.medium"
  type        = string
  description = "The instance type for the Windows Host"
}