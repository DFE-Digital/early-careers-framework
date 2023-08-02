# frozen_string_literal: true

require "rake"

namespace :delivery_partners do
  desc "Exports all delivery partners in CSV format (to a file if specified)"
  task :export, %i[path_to_csv] => :environment do |_task, args|
    exporter = Admin::DeliveryPartners::Exporter.new
    csv_data = exporter.csv
    csv_path = args[:path_to_csv]

    if csv_path.present?
      File.write(csv_path, csv_data)
    else
      puts csv_data
    end
  end
end
