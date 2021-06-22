# frozen_string_literal: true

namespace :s3 do
  desc "Delete attachments from S3 bucket"
  task delete_csvs: :environment do
    exit(0) unless Rails.env.deployed_development?

    PartnershipCsvUpload.find_each do |partnership_csv_upload|
      partnership_csv_upload.csv.purge
    end
  end
end
