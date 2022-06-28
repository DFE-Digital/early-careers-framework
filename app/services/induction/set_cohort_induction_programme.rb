# frozen_string_literal: true

class Induction::SetCohortInductionProgramme < BaseService
  def call
    ActiveRecord::Base.transaction do
      school_cohort.induction_programme_choice = programme_choice
      school_cohort.opt_out_of_updates = opt_out_of_updates

      set_appropriate_body
      # need to save this first if it hasn't been persisted
      school_cohort.save! unless school_cohort.persisted?

      programme = nil

      if InductionProgramme.training_programmes.keys.include? programme_choice
        # NOTE: we could move any participants in the old default programme (if present)
        # over to the new one here but not sure that would always be required?
        programme = InductionProgramme.create!(programme_attrs)
      end

      school_cohort.default_induction_programme = programme
      school_cohort.save!
    end
  end

private

  def set_appropriate_body
    if appropriate_body_type == "unknown"
      school_cohort.appropriate_body_unknown = true
      school_cohort.appropriate_body = nil
    else
      school_cohort.appropriate_body_unknown = false
      school_cohort.appropriate_body_id = appropriate_body
    end
  end

  attr_reader :school_cohort, :programme_choice, :opt_out_of_updates, :core_induction_programme, :delivery_partner_to_be_confirmed,
              :appropriate_body_type, :appropriate_body

  def initialize(school_cohort:, programme_choice:,
                 appropriate_body_type:,
                 appropriate_body:,
                 opt_out_of_updates: false,
                 core_induction_programme: nil,
                 delivery_partner_to_be_confirmed: false)
    # NOTE: this is mainly called during addition of a school_cohort and the model may not
    # be persisted as yet
    @school_cohort = school_cohort
    @programme_choice = programme_choice.to_s
    @opt_out_of_updates = opt_out_of_updates
    @core_induction_programme = core_induction_programme
    @delivery_partner_to_be_confirmed = delivery_partner_to_be_confirmed
    @appropriate_body_type = appropriate_body_type
    @appropriate_body = appropriate_body
  end

  def programme_attrs
    attrs = {
      training_programme: programme_choice,
      school_cohort:,
      delivery_partner_to_be_confirmed:,
    }

    case programme_choice
    when "full_induction_programme"
      attrs[:partnership] = school_cohort.school.partnerships.where(cohort: school_cohort.cohort,
                                                                    relationship: false).active.first
    when "core_induction_programme"
      attrs[:core_induction_programme] = core_induction_programme
    end

    attrs
  end
end
