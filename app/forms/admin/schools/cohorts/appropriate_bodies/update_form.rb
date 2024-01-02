# frozen_string_literal: true

module Admin
  module Schools
    module Cohorts
      module AppropriateBodies
        class UpdateForm
          include ActiveModel::Model
          include ActiveRecord::AttributeAssignment
          include ActiveModel::Serialization

          TEACHING_SCHOOL_HUB_ID = "teaching_school_hub"

          attr_accessor :appropriate_body_id, :teaching_school_hub_id, :school_cohort

          validates :appropriate_body_id, presence: { message: I18n.t("errors.appropriate_body.blank") }
          validates :teaching_school_hub_id, presence: { message: I18n.t("errors.teaching_school_hub.blank") }, if: :teaching_school_hub_selected?
          validate :validate_selected_appropriate_body

          def save!
            school_cohort.update!(appropriate_body_id: selected_appropriate_body_id)
          end

          def radio_options
            @radio_options ||= [
              istip_appropriate_body,
              nta_appropriate_body,
              OpenStruct.new(id: TEACHING_SCHOOL_HUB_ID, name: "A teaching school hub"),
            ].compact
          end

          def selected_appropriate_body_id
            return teaching_school_hub_id if teaching_school_hub_selected?

            appropriate_body_id
          end

          delegate :teaching_school_hubs, to: :appropriate_bodies

        private

          def validate_selected_appropriate_body
            return if selected_appropriate_body_id.blank?
            return if appropriate_bodies.pluck(:id).include?(selected_appropriate_body_id)

            errors.add(:appropriate_body_id, "Please select an appropriate body")
          end

          def teaching_school_hub_selected?
            appropriate_body_id == TEACHING_SCHOOL_HUB_ID
          end

          def appropriate_bodies
            AppropriateBody.active_in_year(cohort_start_year)
          end

          def cohort_start_year
            school_cohort.start_year
          end

          def istip_appropriate_body
            appropriate_bodies.find_by(name: "Independent Schools Teacher Induction Panel (Istip)")
          end

          def nta_appropriate_body
            appropriate_bodies.find_by(name: "National Teacher Accreditation")
          end
        end
      end
    end
  end
end
