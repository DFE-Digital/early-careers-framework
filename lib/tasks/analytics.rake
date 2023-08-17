# frozen_string_literal: true

require "rake"
require 'csv'

namespace :analytics do
  task fields: :environment do
    yaml = YAML.load_file(Rails.root.join("config/analytics_blocklist.yml"))
    entities = yaml[:shared]
    
    CSV.open(Rails.root.join("fields.csv"), 'w') do |writer|
      entities.each do |entity, fields|
        writer << [entity]
        fields.each do |field|
          writer << [nil, field]
        end
      end
    end
  end
end
