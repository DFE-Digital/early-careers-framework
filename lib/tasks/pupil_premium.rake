# frozen_string_literal: true

require "rake"

namespace :pupil_premium do
  desc "Import pupil premium data from CSV"
  task import: :environment do
    puts "Importing pupil premium data, this may take a couple minutes..."
    [2021, 2022].each do |year|
      file = Rails.root.join("data", "pupil_premium_and_sparsity_#{year}.csv")
      Importers::PupilPremium.call(start_year: year, path_to_source_file: file)
    end
    puts "Pupil premium data import complete!"
  end
end
