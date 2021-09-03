# frozen_string_literal: true

require "google/cloud/bigquery"
require "base64"

Google::Cloud::Bigquery.configure do |config|
  config.project_id = "ecf-bq"

  if Rails.application.credentials.GOOGLE_BQ_SERVICE_ACCOUNT_BASE64
    config.credentials = JSON.parse(Base64.decode64(Rails.application.credentials.GOOGLE_BQ_SERVICE_ACCOUNT_BASE64))
  end
end
