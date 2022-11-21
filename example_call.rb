# frozen_string_literal: true

require "sample_data/generators/support/generator_util"
require "sample_data/generators/school_generator"
require "sample_data/generators/school_cohort_generator"
require "sample_data/generators/mentor_generator"
require "sample_data/generators/user_generator"
require "sample_data/generators/teacher_profile_generator"
require "sample_data/generators/participant_identity_generator"

generator = SampleData::Generators::SchoolGenerator.generate do |sg|
  sg.with_cohort(start_year: 2021)
  sg.with_mentor
end
