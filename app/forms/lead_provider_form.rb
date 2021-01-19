# frozen_string_literal: true

class LeadProviderForm
  include ActiveModel::Model

  attr_accessor :name, :cip, :cohorts

  def available_cips
    Cip.all
  end

  def available_cohorts
    Cohort.all
  end

  def chosen_cohorts
    Cohort.where(id: cohorts)
  end

  def chosen_cohort_names
    cohorts.map { |id| Cohort.find(id).display_name }
           .join(", ")
  end

  def chosen_cip
    Cip.find(cip)
  end

  def chosen_cip_name
    Cip.find(cip).name
  end
end
