# frozen_string_literal: true

require "rake"

namespace :pupil_premium do
  desc "Import pupil premium and sparsity data from CSV"
  task import: :environment do
    puts "Importing pupil premium data, this may take a couple minutes..."
    Cohort.pluck(:start_year).sort.each do |year|
      file = Rails.root.join("data", "pupil_premium_and_sparsity_#{year}.csv")
      if file.exist?
        puts "Importing data for #{year} ..."
        Importers::PupilPremium.call(start_year: year, path_to_source_file: file)
      end
    end
    puts "Pupil premium and sparsity data import complete!"
  end
end
