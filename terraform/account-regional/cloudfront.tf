resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "origin-access-identity/cloudfront/"
}
resource "aws_cloudfront_origin_access_identity" "origin_access_identity_mediastorage" {
  comment = "origin-access-identity/cloudfront/"
}


### Mediastorage 
resource "aws_cloudfront_distribution" "s3_distribution_2" {
	  
	origin {
		domain_name = "${aws_s3_bucket.s3bucket_2.bucket_regional_domain_name}"
		origin_id   = "${var.Environment}-${var.Application}-mediastorage"

		s3_origin_config {
			origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity_mediastorage.cloudfront_access_identity_path}"
		}
	}
	enabled             = true
	is_ipv6_enabled     = true
	default_root_object = "index.html"

	default_cache_behavior {
		allowed_methods  = ["GET", "HEAD"]
		cached_methods   = ["GET", "HEAD"]
		target_origin_id = "${var.Environment}-${var.Application}-mediastorage"

		forwarded_values {
			query_string = false
			cookies { 
				forward = "none"
			}
		}

		trusted_signers        = ["self"]
		viewer_protocol_policy = "allow-all"
		min_ttl                = 1800
		default_ttl            = 3600
		max_ttl                = 7200
	}
	restrictions {
		geo_restriction {
		restriction_type = "none"
		}
	}


    viewer_certificate {
        cloudfront_default_certificate = true
    }
	#web_acl_id = ""
	
	### TAGS ###
	tags = {
        Role = "${var.Role[0]}"
        Tribe = "${var.Tribe}"
        Environment = "${var.Environment}"
        Name = "${var.Environment}-${var.Role[0]}-${var.Application}-mediastorage"
        Application = "${var.Application}"
        Region = "${var.region}"
        Tier = "${var.Tier}"
        Owner = "${var.Owner}"
        Tool_Name = "${var.Tool_Name}"
        Tool_Task = "${var.Tool_Task}"
	}
}