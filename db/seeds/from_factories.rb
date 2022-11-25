# frozen_string_literal: true

# Nathan's wishlist:
#
# I'd add in a few participants who:
# * have transferred to that school and continued with their original training
#   provider (i.e. have a relationship rather than a partnership)
# * have transferred to that school and now adopted the new school's training provision
# * are mentoring >1 ECT and those ECTs are all being trained by the same provider
# * are mentoring >1 ECT and those ECTs are not all being trained by the same provider
# * is due to leave the school
# * has left the school
# * are representative of the main schedules as well the cohorts e.g.
#   ecf-standard-september versus jan/apr and versus
#   extended/reduced/replacement

class FipToFip
  def initialize; end

  def setup
    school_1 = FactoryBot.create(:seed_school)
    school_2 = FactoryBot.create(:seed_school)

    user_1 = FactoryBot.create(:seed_user)
    _teacher_profile = FactoryBot.create(:seed_teacher_profile, user: user_1, school: school_1)

    # create two lead providers
    _lead_provider_1 = FactoryBot.create(:seed_lead_provider)
    _lead_provider_2 = FactoryBot.create(:seed_lead_provider)

    # create two delivery_partners
    _delivery_partner_1 = FactoryBot.create(:seed_delivery_partner)
    _delivery_partner_2 = FactoryBot.create(:seed_delivery_partner)

    # create school cohorts
    _school_cohort_1 = FactoryBot.create(:seed_school_cohort, cohort: cohort_2021, school: school_1)
    _school_cohort_2 = FactoryBot.create(:seed_school_cohort, cohort: cohort_2021, school: school_2)

    # create partnerships between lead providers, delivery partners, cohorts and schools
    # do a transfer
    #   * there should be a Partnershp with `relationship: true` between the new school
    #     and the lead provider of the old school
    # create a FIP induction programme that has the new (relationship) partnership above set
    # enrol the participant to the new programme (aka create an induction record)
  end

  def cohort_2021
    Cohort.find_by!(start_year: 2021)
  end

  def cohort_2022
    Cohort.find_by!(start_year: 2022)
  end
end

FipToFip.new.setup
