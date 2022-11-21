# frozen_string_literal: true

require "pry"

Faker::Config.locale = "en-GB"

# the goal is to be able to generate data with something like:
# SampleData.scenario do
#   school name: "Big School", urn: "123456"
#   induction_programme type: "full_induction_programme", year: 2021
#   mentor name: "Kelly Evans"
#   mentor name: "Todd King", as: :mentor_todd
#   ect name: "John Whelk", mentor: :mentor_todd
#   ect name: "Tom Cockles", mentor: :mentor
# end

module SampleData
  def self.scenario(&block)
    scenario = Scenario.new
    scenario.instance_eval(&block)
    scenario.create
    scenario
  end

  class Scenario
    def initialize
      @entity_queue = {}
      @register = {}
    end

    def create
      @entity_queue.each do |k,v|
        # generate each entity
        # the generators should call back for items they are missing
        # and the scenario should check the register, then entity_queue, then create a default object
        # adding to the register anything created
        generate_resource(k, v[0], **v[1]) unless registered?(k)
      end
    end

    def fetch(key)
      # attempt to find a resource by a key
      # 1. look in @register for built resources
      # 2. look in @entity_queue for resources not yet built
      # 3. invoke the generator for that resource to build a default version
      if registered?(key)
        puts "fetching registered:#{key}"
        @register[key]
      elsif @entity_queue.key?(key)
        puts "building queued:#{key}"
        resource = @entity_queue[key]
        generate_resource(key, resource[0], **resource[1])
      else
        puts "building a default:#{key}"
        generate_resource(key, generator_class(key))
      end
    end

  private

    def method_missing(m, *args, **kwargs, &block)
      entity = m
      key_name = kwargs.key?(:as) ? kwargs[:as] : entity

      @entity_queue[key_name] = [generator_class(entity), kwargs]
      debugger
    end

    def generate_resource(key, generator, **kwargs)
      raise "Resource already registered with key '#{key}'" if @register.key?(key)

      @register[key] = generator.new(self, **kwargs).create
    end

    def registered?(key)
      @register.key?(key)
    end

    # def key_or_key_as(key, **kwargs)
    #   kwargs.key?(:as) ? kwargs[:as] : key
    # end

    def generator_class(name)
      puts "generator #{name}"
      "sample_data/#{name}_generator".classify.constantize
    end
  end

  class BaseGenerator
    attr_reader :scenario, :options

    def initialize(scenario, **kwargs)
      @scenario = scenario
      @options = kwargs
    end

    def fetch_dependency(key)
      key_name = options.fetch(key, key)
      scenario.fetch(key_name)
    end
  end

  # sample_data/school_generator.rb
  class SchoolGenerator < BaseGenerator
    def create
      "build a school - #{options}"
    end
  end

  # sample_data/induction_tutor_generator.rb
  class PartnershipGenerator < BaseGenerator
    def create
      school = fetch_dependency(:school)
      # lp = fetch_dependency(:lead_provider)
      # dp = fetch_dependency(:delivery_partner)
      # cohort = fetch_dependency(:cohort)

      puts "build a partnership - #{options}"
    end
  end

  # sample_data/school_cohort_generator.rb
  class SchoolCohortGenerator < BaseGenerator
    def create
      "build a school_cohort - #{options}"
      school = fetch_dependency(:school)
      cohort = fetch_dependency(:cohort)
    end
  end

  # sample_data/school_cohort_generator.rb
  class CohortGenerator < BaseGenerator
    def create
      "build a cohort - #{options}"
    end
  end


  # sample_data/induction_tutor_generator.rb
  class InductionTutorGenerator < BaseGenerator
    def create
      "build an induction tutor - #{options}"
      school = fetch_dependency(:school)
    end
  end
end

