# frozen_string_literal: true

if Rails.application.config.x.vcap_services.present?

  if ENV["BUCKET_NAME"].blank?
    bucket_name = Rails.application.config.x.vcap_services.dig(
      "aws-s3-bucket", 0, "credentials", "bucket_name"
    )
    ENV["BUCKET_NAME"] = bucket_name if bucket_name.present?
  end

  if ENV["AWS_ACCESS_KEY_ID"].blank?
    aws_access_key_id = Rails.application.config.x.vcap_services.dig(
      "aws-s3-bucket", 0, "credentials", "aws_access_key_id"
    )
    ENV["AWS_ACCESS_KEY_ID"] = aws_access_key_id if aws_access_key_id.present?
  end

  if ENV["AWS_SECRET_ACCESS_KEY"].blank?
    aws_secret_access_key = Rails.application.config.x.vcap_services.dig(
      "aws-s3-bucket", 0, "credentials", "aws_secret_access_key"
    )
    ENV["AWS_SECRET_ACCESS_KEY"] = aws_secret_access_key if aws_secret_access_key.present?
  end

  if ENV["AWS_REGION"].blank?
    aws_region = Rails.application.config.x.vcap_services.dig(
      "aws-s3-bucket", 0, "credentials", "aws_region"
    )
    ENV["AWS_REGION"] = aws_region if aws_region.present?
  end

end
