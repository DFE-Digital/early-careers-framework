# frozen_string_literal: true

# store all seeds inside the folder db/seeds

Dir[Rails.root.join("db/seeds/dummy_structures.rb")].each { |seed| load seed }

CURRENT_CIP_VERSION = 3
CourseLesson.where("version < ?", CURRENT_CIP_VERSION).delete_all
CourseModule.where("version < ?", CURRENT_CIP_VERSION).delete_all
CourseYear.where("version < ?", CURRENT_CIP_VERSION).delete_all

Dir[Rails.root.join("db/seeds/cip_ambition.rb")].each { |seed| load seed }
Dir[Rails.root.join("db/seeds/cip_edt.rb")].each { |seed| load seed }
Dir[Rails.root.join("db/seeds/cip_teachfirst.rb")].each { |seed| load seed }
Dir[Rails.root.join("db/seeds/cip_ucl.rb")].each { |seed| load seed }

unless Cohort.first
  Cohort.create!(start_year: 2021)
  Cohort.create!(start_year: 2022)
end
