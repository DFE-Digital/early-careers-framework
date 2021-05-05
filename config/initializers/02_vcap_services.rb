# frozen_string_literal: true

if Rails.application.config.x.vcap_services.present?

  csv_bucket = Rails.application.config.x.vcap_services["aws-s3-bucket"].select { |bucket| bucket["name"].include?("csv") }.dig(0, "credentials")

  if ENV["CSV_BUCKET_NAME"].blank?
    bucket_name = csv_bucket.dig "bucket_name"

    ENV["CSV_BUCKET_NAME"] = bucket_name if bucket_name.present?
  end

  if ENV["CSV_AWS_ACCESS_KEY_ID"].blank?
    aws_access_key_id = csv_bucket.dig "aws_access_key_id"

    ENV["CSV_AWS_ACCESS_KEY_ID"] = aws_access_key_id if aws_access_key_id.present?
  end

  if ENV["CSV_AWS_SECRET_ACCESS_KEY"].blank?
    aws_secret_access_key = csv_bucket.dig "aws_secret_access_key"

    ENV["CSV_AWS_SECRET_ACCESS_KEY"] = aws_secret_access_key if aws_secret_access_key.present?
  end

  if ENV["CSV_AWS_REGION"].blank?
    aws_region = csv_bucket.dig "aws_region"

    ENV["CSV_AWS_REGION"] = aws_region if aws_region.present?
  end

end
