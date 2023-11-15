/*
This block creates the cloudtrail that collects all management events, API insights,
and all lambda and S3 object logs.It is set up as a multi-region and organization trail.
*/
resource "aws_cloudtrail" "org_cloudtrail" {
  name                          = var.trail_name
  s3_bucket_name                = aws_s3_bucket.cloudtrail_bucket.id
  include_global_service_events = true
  is_multi_region_trail         = true
  is_organization_trail         = true
  enable_log_file_validation    = true
  depends_on                    = [aws_s3_bucket.cloudtrail_bucket]

  event_selector {
    read_write_type           = "All"
    include_management_events = true
    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::"]
    }
  }

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::Lambda::Function"
      values = ["arn:aws:lambda"]
    }
  }

  insight_selector {
    insight_type = "ApiCallRateInsight"
  }
}