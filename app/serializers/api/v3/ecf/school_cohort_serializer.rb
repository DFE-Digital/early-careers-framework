# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

module Api
  module V3
    module ECF
      class SchoolCohortSerializer
        include JSONAPI::Serializer
        include JSONAPI::Serializer::Instrumentation

        set_id :school_id
        set_type :school

        attributes :name,
                   :urn,
                   :cohort,
                   :in_partnership,
                   :induction_programme_choice,
                   :updated_at

        attribute :name do |school_cohort|
          school_cohort.school.name
        end

        attribute :urn do |school_cohort|
          school_cohort.school.urn
        end

        attribute :cohort do |school_cohort|
          school_cohort.cohort.start_year.to_s
        end

        attribute :in_partnership do |school_cohort|
          school_cohort.school.partnered?(school_cohort.cohort)
        end

        attribute :updated_at, &:updated_at
      end
    end
  end
end
