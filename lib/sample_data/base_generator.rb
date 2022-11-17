# frozen_string_literal: true

require "pry"

Faker::Config.locale = "en-GB"

# the goal is to be able to generate data with something like:
#
# SampleData::Generator
#   .create_school
#   .with_cohort(2021)
#   .with_mentors(count: 2)
#   .with_mentors(count: 1, deferred: true)
#   .with_ects(count: 4)
#
# SampleData::Generator
#   .find_school(
# SampleData::Generator.create(entity: :school, urn: 123456, name: "Big School").with_induction_programme(:full_induction_programme, year: 2021)
#
# SampleData::Generator.new.create_school(urn: 123456).with_school_cohort(year: 2022)

# SampleData::Generator.create_school(urn: 123456)  do |school|
#  school.create_induction_programme(choice: :fip, year: 2022) do |induction_programme|
#     induction_programme.create_mentor
#     induction_programme.create_ect
#  end
#
module SampleData
  class BaseGenerator
    attr_accessor :entity

    def method_missing(m, *args, **kwargs, &block)
      names = m.to_s.split("_")
      entity_name = names[1..].join("_")

      if names[0] == "create"
        generator_class(entity_name).new.create(*args, **kwargs, &block)
      elsif names[0].in? %w[with and in]
        # tap { generator_class(entity_name).new.create(*args, **add_self_as_param_to(**kwargs), &block) }
        generator_class(entity_name).new.create(*args, **add_self_as_param_to(**kwargs), &block)
      else
        super
      end
    end

    def add_self_as_param_to(**kwargs)
      return **kwargs if entity.nil?
      { entity_key => entity }.merge(kwargs)
    end

    def entity_key
      entity.class.name.snakecase
    end

    def generator_class(name)
      "sample_data/#{name}_generator".classify.constantize
    end
  end

  # sample_data/school_generator.rb
  class SchoolGenerator < BaseGenerator
    def create(**kwargs, &block)
      @entity = "build a school"
      puts "#{entity} - #{kwargs}"
      yield self if block_given?
      self
    end
  end

  # sample_data/school_cohort_generator.rb
  class SchoolCohortGenerator < BaseGenerator
    def create(**kwargs, &block)
      @entity = "build a school cohort"
      puts "#{entity} - #{kwargs}"
      yield self if block_given?
      self
    end
  end

  # sample_data/induction_tutor_generator.rb
  class InductionTutorGenerator < BaseGenerator
    def create(**kwargs, &block)
      @entity = "build an induction tutor"
      puts "#{entity} - #{kwargs}"
      yield self if block_given?
      self
    end

    def entity_key
      :induction_coordinator_profile
    end
  end
end
