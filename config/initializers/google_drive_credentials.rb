# frozen_string_literal: true

# Google's API client expects these ENV variables to be set. If we have them in
# our application credentials copy them to the ENV
%i[
  GOOGLE_CLIENT_ID
  GOOGLE_CLIENT_EMAIL
  GOOGLE_ACCOUNT_TYPE
  GOOGLE_PRIVATE_KEY
  GOOGLE_DRIVE_NPQ_UPLOAD_FOLDER_ID
  GOOGLE_DRIVE_NPQ_DOWNLOAD_FOLDER_ID
].each do |identifier|
  next if ENV.key?(identifier.to_s)

  if Rails.application.credentials.config.key?(identifier)
    ENV[identifier.to_s] = Rails.application.credentials.config[identifier].to_s
  end
end
