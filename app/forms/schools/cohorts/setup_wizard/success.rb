# frozen_string_literal: true

module Schools
  module Cohorts
    class SetupWizard
      module Success
        def success
          ActiveRecord::Base.transaction do
            if !expect_any_ects?
              set_cohort_induction_programme!(:no_early_career_teachers, opt_out_of_updates: true)
            elsif keep_providers?
              active_partnership? ? save_appropriate_body : use_the_same_training_programme!
            elsif what_changes.present?
              set_cohort_induction_programme!(what_changes_programme)
              send_fip_programme_changed_email! if previously_fip?
            else
              set_cohort_induction_programme!(how_will_you_run_training)
            end

            if should_send_the_pilot_survey?
              SchoolMailer
                .with(sit_user: current_user)
                .cohortless_pilot_2023_survey_email
                .deliver_later(wait: 3.hours)
            end
          end
        end

      private

        def active_partnership?
          school.active_partnerships.where(cohort:, relationship: false).exists?
        end

        def build_partnership_with_previous_training_programme
          school.active_partnerships
          .find_by(cohort: previous_cohort, relationship: false)
          .dup
          .tap do |partnership|
            partnership.cohort_id = cohort.id
          end
        end

        def find_partnership_with_same_training_programme(partnerhip)
          school.partnerships
                .find_by(cohort:,
                         lead_provider: partnerhip.lead_provider,
                         delivery_partner: partnerhip.delivery_partner)
        end

        def save_appropriate_body
          Induction::SetSchoolCohortAppropriateBody.call(school_cohort:,
                                                         appropriate_body_id:,
                                                         appropriate_body_appointed: appropriate_body_appointed?)
        end

        def send_fip_programme_changed_email!
          previous_partnership = previous_school_cohort.default_induction_programme.partnership

          if previous_partnership.blank?
            msg = "no previous partnership found for cohort #{previous_school_cohort.id}"
            Sentry.capture_message(msg, level: :warning)
            return Rails.logger.warn(msg)
          end

          previous_partnership.lead_provider.users.each do |lead_provider_user|
            LeadProviderMailer.with(
              partnership: previous_partnership,
              user: lead_provider_user,
              cohort_year: school_cohort.academic_year,
              what_changes_choice: what_changes,
            ).programme_changed_email.deliver_later
          end
        end

        def set_cohort_induction_programme!(programme_choice, opt_out_of_updates: false)
          Induction::SetCohortInductionProgramme.call(school_cohort:,
                                                      programme_choice:,
                                                      opt_out_of_updates:,
                                                      delivery_partner_to_be_confirmed: delivery_partner_to_be_confirmed?)
          save_appropriate_body
        end

        def use_the_same_training_programme!
          new_partnership = build_partnership_with_previous_training_programme
          existing_partnership = find_partnership_with_same_training_programme(new_partnership)
          (existing_partnership || new_partnership).unchallenge!
          set_cohort_induction_programme!(:full_induction_programme)
        end

        def what_changes_programme
          @what_changes_programme ||= {
            change_lead_provider: :full_induction_programme,
            change_delivery_partner: :full_induction_programme,
            change_to_core_induction_programme: :core_induction_programme,
            change_to_design_our_own: :design_our_own,
          }[what_changes.to_sym]
        end

        def should_send_the_pilot_survey?
          cohort.start_year == 2023 && FeatureFlag.active?(:cohortless_dashboard, for: school) &&
            expect_any_ects? && current_user.induction_coordinator?
        end
      end
    end
  end
end
