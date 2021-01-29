# frozen_string_literal: true

desc "Dump CIP content into a file"
task cip_seed_dump: :environment do
  system "bundle exec rake db:seed:dump FILE=db/seeds/cip_seed_dump.rb EXCLUDE='[:created_at, :updated_at]' MODELS='CoreInductionProgramme, CourseYear, CourseModule, CourseLesson' IMPORT=true"
end
