data "aws_caller_identity" "current" {

}

data "aws_region" "current" {

}

data "aws_s3_bucket" "appsettings" {
  bucket = var.appstream_app_settings_bucket
}