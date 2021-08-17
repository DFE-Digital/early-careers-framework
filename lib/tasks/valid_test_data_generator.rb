# frozen_string_literal: true

require "tasks/school_urn_generator"
require "tasks/trn_generator"

module ValidTestDataGenerator
  class LeadProviderPopulator
    class << self
      def call(name:, total_schools: 10, participants_per_school: 100)
        new(name: name).call(total_schools: total_schools, participants_per_school: participants_per_school)
      end
    end

    def call(total_schools: 10, participants_per_school: 100)
      generate_new_schools(count: total_schools - lead_provider.schools.count) if lead_provider.schools.count < total_schools
      lead_provider.schools.order("created_at desc").limit(total_schools).each do |school|
        find_or_create_participants(school: school, number_of_participants: participants_per_school)
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

    def find_or_create_participants(school:, number_of_participants:)
      generate_new_participants(school: school, count: number_of_participants - school.ecf_participants.count) if school.ecf_participants.count < number_of_participants
      school.ecf_participants.order("created_at desc").limit(number_of_participants).to_a
    end

    def generate_new_participants(school:, count:)
      ((count + 1) / 2).times do
        status = (%w[active] * 6 + %w[withdrawn]).sample
        mentor = create_participant(school_cohort: school_cohort(school: school), profile_klass: ParticipantProfile::Mentor, status: status)
        create_participant(school_cohort: school_cohort(school: school), profile_klass: ParticipantProfile::ECT, mentor_profile: mentor, status: status)
      end
    end

    def create_participant(school_cohort:, profile_klass: ParticipantProfile::ECT, mentor_profile: nil, status: "active")
      name = Faker::Name.name
      user = User.create!(full_name: name, email: Faker::Internet.email(name: name))
      teacher_profile = TeacherProfile.create!(user: user, trn: random_or_nil_trn)
      if profile_klass == ParticipantProfile::ECT
        ParticipantProfile::ECT.create!(teacher_profile: teacher_profile, school_cohort: school_cohort, mentor_profile: mentor_profile, status: status)
      else
        ParticipantProfile::Mentor.create!(teacher_profile: teacher_profile, school_cohort: school_cohort, status: status)
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
        s.sparsity_uplift = ([true] * 11 + [false] * 89).sample
        s.pupil_premium = ([true] * 11 + [false] * 39).sample
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
  end
end
