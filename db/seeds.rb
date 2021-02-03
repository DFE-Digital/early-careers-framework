# frozen_string_literal: true

# store all seeds inside the folder db/seeds

CourseLesson.delete_all
CourseModule.delete_all
CourseYear.delete_all

Dir[Rails.root.join("db/seeds/cip_seed.rb")].each { |seed| load seed }

Dir[Rails.root.join("db/seeds/dummy_structures.rb")].each { |seed| load seed }
