# frozen_string_literal: true

module Admin::Performance
  class OverviewController < Admin::BaseController
    skip_after_action :verify_authorized, only: :show
    skip_after_action :verify_policy_scoped, only: :show

    # show active registration cohort stats
    def show
      @pilot_stats = get_registration_stats
    end

    helper_method :cip_label, :fip_label

  private

    def cip_label
      if FeatureFlag.active?(:programme_type_changes_2025)
        "Delivering school-led training"
      else
        "Delivering their training using DfE materials"
      end
    end

    def fip_label
      if FeatureFlag.active?(:programme_type_changes_2025)
        "Using provider-led training"
      else
        "Using a training provider (full induction programme)"
      end
    end

    def get_registration_stats
      choices = programme_choices

      if FeatureFlag.active?(:programme_type_changes_2025)
        OpenStruct.new({
          cohort:,
          cip_total: choices.fetch("core_induction_programme", 0) + choices.fetch("design_our_own", 0),
          fip_total: choices.fetch("full_induction_programme", 0),
          no_ects_total: choices.fetch("no_early_career_teachers", 0),
          total: choices.values.sum,
          partnership_totals:,
          ect_count: participants_registered.ects.count,
          mentors_count: participants_registered.mentors.count,
          total_participants: participants_registered.count,
        })
      else
        OpenStruct.new({
          cohort:,
          cip_total: choices.fetch("core_induction_programme", 0),
          diy_total: choices.fetch("design_our_own", 0),
          fip_total: choices.fetch("full_induction_programme", 0),
          no_ects_total: choices.fetch("no_early_career_teachers", 0),
          total: choices.values.sum,
          partnership_totals:,
          ect_count: participants_registered.ects.count,
          mentors_count: participants_registered.mentors.count,
          total_participants: participants_registered.count,
        })
      end
    end

    def programme_choices
      SchoolCohort.where(cohort:, induction_programme_choice: valid_choices).group(:induction_programme_choice).count
    end

    def partnership_totals
      totals = Partnership.unchallenged.where(cohort:).group(:lead_provider_id).count

      providers.map do |provider|
        { name: provider.name, total: totals.fetch(provider.id, 0) }
      end
    end

    def providers
      LeadProvider.where(id: ProviderRelationship.where(cohort:).select(:lead_provider_id)).name_order
    end

    def participants_registered
      @participants_registered ||= ParticipantProfile::ECF.where(id: InductionRecord.active
                                                                                    .joins(schedule: :cohort)
                                                                                    .where(schedule: { cohort: })
                                                                                    .select(:participant_profile_id))
    end

    def valid_choices
      SchoolCohort.induction_programme_choices.keys - %w[school_funded_fip not_yet_known]
    end

    def cohort
      @cohort ||= Cohort.active_registration_cohort
    end
  end
end
