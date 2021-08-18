# frozen_string_literal: true

require "tasks/school_urn_generator"
require "tasks/trn_generator"

module ValidTestDataGenerator
  class LeadProviderPopulater
    class << self
      def call(name:, total_schools: 10, participants_per_school: 100)
        new(name: name).call(total_schools: total_schools, participants_per_school: participants_per_school)
      end
    end

    def call(total_schools: 10, participants_per_school: 100)
      generate_new_schools(count: total_schools - lead_provider.schools.count) if lead_provider.schools.count < total_schools
      lead_provider.schools.order("created_at desc").limit(total_schools).each do |school|
        sparsity_uplift = weighted_choice(selection: [true, false], odds: [11, 89])
        pupil_premium_uplift = weighted_choice(selection: [true, false], odds: [11, 39])
        find_or_create_participants(school: school, number_of_participants: participants_per_school, sparsity_uplift: sparsity_uplift, pupil_premium_uplift: pupil_premium_uplift)
      end
    end

  private

    attr_reader :lead_provider

    def initialize(name:)
      @lead_provider = ::LeadProvider.find_or_create_by!(name: name)
    end

    def generate_new_schools(count:)
      count.times { create_fip_school_with_cohort(urn: SchoolURNGenerator.next) }
    end

    def find_or_create_participants(school:, number_of_participants:, sparsity_uplift:, pupil_premium_uplift:)
      generate_new_participants(school: school, count: number_of_participants - school.ecf_participants.count, sparsity_uplift: sparsity_uplift, pupil_premium_uplift: pupil_premium_uplift) if school.ecf_participants.count < number_of_participants
    end

    def generate_new_participants(school:, count:, sparsity_uplift:, pupil_premium_uplift:)
      while count.positive?
        status = weighted_choice(selection: %w[active withdrawn], odds: [6, 1])
        profile_type = weighted_choice(selection: %i[mentor ect], odds: [9, 1])
        count -= 1
        if profile_type == :mentor
          mentor = create_participant(school_cohort: school_cohort(school: school), profile_type: :mentor, status: status, sparsity_uplift: sparsity_uplift, pupil_premium_uplift: pupil_premium_uplift)
          rand(0..3).times do
            create_participant(school_cohort: school_cohort(school: school), profile_type: :ect, mentor_profile: mentor, status: status, sparsity_uplift: sparsity_uplift, pupil_premium_uplift: pupil_premium_uplift)
            count -= 1
          end
        else
          create_participant(school_cohort: school_cohort(school: school), profile_type: :ect, status: status, sparsity_uplift: sparsity_uplift, pupil_premium_uplift: pupil_premium_uplift)
        end
      end
    end

    def create_participant(school_cohort:, profile_type: :ect, mentor_profile: nil, status: "active", sparsity_uplift: false, pupil_premium_uplift: false)
      name = Faker::Name.name
      user = User.create!(full_name: name, email: Faker::Internet.email(name: name))
      teacher_profile = TeacherProfile.create!(user: user, trn: random_or_nil_trn)
      schedule = Finance::Schedule.default
      if profile_type == :ect
        ParticipantProfile::ECT.create!(teacher_profile: teacher_profile, school_cohort: school_cohort, mentor_profile: mentor_profile, status: status, sparsity_uplift: sparsity_uplift, pupil_premium_uplift: pupil_premium_uplift, schedule: schedule)
      else
        ParticipantProfile::Mentor.create!(teacher_profile: teacher_profile, school_cohort: school_cohort, status: status, sparsity_uplift: sparsity_uplift, pupil_premium_uplift: pupil_premium_uplift, schedule: schedule)
      end
    end

    def school_cohort(school:)
      SchoolCohort.find_or_create_by!(school: school, cohort: Cohort.current, induction_programme_choice: "full_induction_programme")
    end

    def create_fip_school_with_cohort(urn:)
      school = School.find_or_create_by!(urn: urn) do |s|
        s.name = Faker::Company.name
        s.address_line1 = Faker::Address.street_address
        s.postcode = Faker::Address.postcode
      end
      school_cohort(school: school)
      attach_partnership_to_school(school: school)
    end

    def attach_partnership_to_school(school:)
      Partnership.find_or_create_by!(
        school: school,
        lead_provider: lead_provider,
        cohort: Cohort.current,
      ) do |partnership|
        partnership.delivery_partner = DeliveryPartner.create!(name: Faker::Company.name)
        ProviderRelationship.find_or_create_by!(
          lead_provider: lead_provider,
          cohort: Cohort.current,
          delivery_partner: partnership.delivery_partner,
        )
      end
    end

    def random_or_nil_trn
      [true, false].sample ? nil : TRNGenerator.next
    end

    def weighted_choice(selection:, odds:)
      selection.each_with_index.map { |item, index|
        [item] * odds[index]
      }.flatten.sample
    end
  end
end
