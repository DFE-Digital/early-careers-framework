# frozen_string_literal: true

desc "Dump CIP content into a file"
task cip_seed_dump: :environment do
  CoreInductionProgrammeExporter.new.run
end
