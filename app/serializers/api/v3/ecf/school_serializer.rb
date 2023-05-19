# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

module Api
  module V3
    module ECF
      class SchoolSerializer
        include JSONAPI::Serializer
        include JSONAPI::Serializer::Instrumentation

        class << self
          def school_cohort_for(school:, cohort:)
            school.school_cohorts.detect { |school_cohort| school_cohort.cohort == cohort }
          end
        end

        set_id :id
        set_type :school

        attributes :name,
                   :urn,
                   :cohort,
                   :in_partnership,
                   :induction_programme_choice,
                   :created_at,
                   :updated_at

        attribute :name, &:name
        attribute :urn, &:urn

        attribute :cohort do |_school, params|
          params[:cohort]&.start_year&.to_s
        end

        attribute :in_partnership do |school, params|
          return false if params[:cohort].blank?

          school.partnered?(params[:cohort])
        end

        attribute :induction_programme_choice do |school, params|
          school_cohort = school_cohort_for(school:, cohort: params[:cohort])
          school_cohort&.induction_programme_choice.presence || "not_yet_known"
        end

        attribute :created_at do |school|
          school.created_at.rfc3339
        end

        attribute :updated_at do |school, params|
          school_cohort = school_cohort_for(school:, cohort: params[:cohort])
          [school.updated_at, school_cohort&.updated_at].compact.max.rfc3339
        end
      end
    end
  end
end
