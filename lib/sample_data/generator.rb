# frozen_string_literal: true

require "pry"

Faker::Config.locale = "en-GB"

# the goal is to be able to generate data with something like:
#
# SampleData::Generator
#   .create_school
#   .with_cohort(2021)
#   .with_mentors(count: 2)
#   .with_mentors(count: 1, deferred: true)
#   .with_ects(count: 4)
#
# SampleData::Generator
#   .find_school(
module SampleData
  class Generator
    class CreationOrderError < StandardError; end

    attr_reader :school, :mentors, :cohort

    def initialize
      @mentors = []
    end

    def generate_school(**kwargs)
      suffix = %w[Nursery Primary Secondary Grammar College]

      attrs = {
        name: "#{Faker::Address.city} #{suffix.sample}",
        urn: rand(10_000..10_000_000),
        address_line1: Faker::Address.street_address,
        postcode: Faker::Address.postcode,
      }

      @school = School.create!(**attrs.merge(kwargs))

      self
    end

    def find_school(urn: nil, id: nil)
      @school = (id ? School.find(id) : School.find_by!(urn:))
    end

    def with_cohort(year, **kwargs)
      @cohort = Cohort.find_by!(start_year: year)

      @school_cohort = @school.school_cohorts.create!(
        cohort:,
        **{ induction_programme_choice: "full_induction_programme" }.merge(kwargs),
      )

      self
    end

    def with_mentors(count: 1, **kwargs)
      count.times { create_mentor(**kwargs) }

      self
    end

    def with_ects(count: 1, **kwargs)
      count.times { create_ect(**kwargs) }

      self
    end

  private

    def create_mentor(**kwargs)
      user = create_user
      teacher_profile = create_teacher_profile(user:)
      participant_identity = create_participant_identity(user:)

      fail(CreationOrderError, "create teacher profile before other profile") unless teacher_profile

      @mentors << ParticipantProfile::Mentor.new(**kwargs) do |m|
        m.teacher_profile = teacher_profile
        m.participant_identity = participant_identity
        m.school_cohort = @school_cohort
        m.schedule = Finance::Schedule.first

        m.save!
      end
    end

    def create_ect
      # blah
    end

    def create_user
      User.create! do |u|
        u.email = Faker::Internet.unique.safe_email
        u.full_name = Faker::Name.name
      end
    end

    def create_teacher_profile(user:)
      fail(CreationOrderError, "create user before teacher profile") unless user

      TeacherProfile.create! do |tp|
        tp.user = user
        tp.trn = rand(10_000..10_000_000)
      end
    end

    def create_participant_identity(user:)
      fail(CreationOrderError, "create user before participant identity") unless user

      @participant_identity = ParticipantIdentity.create! do |tp|
        tp.user = user
        tp.external_identifier = user.id
        tp.email = "#{user.id}@example.com"
      end
    end
  end
end
