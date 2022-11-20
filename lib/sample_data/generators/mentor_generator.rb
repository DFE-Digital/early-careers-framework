# frozen_string_literal: true

require_relative "./support/generator_util"

module SampleData
  module Generators
    class MentorGenerator
      extend SampleData::Generators::Support::GeneratorClassUtil

      attr_reader :overrides, :user, :teacher_profile, :participant_identity, :mentor

      def initialize(overrides = {})
        @overrides = overrides
      end

      def generate
        Rails.logger.debug("generating mentor")

        @mentor = ParticipantProfile::Mentor.create!(**attributes)

        Rails.logger.debug("generating mentor: mentor #{@mentor.id} created")

        self
      end

    private

      def attributes
        { schedule: Finance::Schedule.first }.merge(overrides).tap do |a|
          # the mentor requires a teacher profile and user record
          # if these were provided they'll be in `a`, if not we need
          # to generate them

          if a.key?(:user)
            Rails.logger.debug("generating mentor: user present, using #{a[:user].id}")
          else
            @user = SampleData::Generators::UserGenerator.generate

            Rails.logger.debug("generating mentor: generated user #{@user.user.id}")

            a[:user] = @user.user
          end

          if a.key?(:participant_identity)
            Rails.logger.debug("generating mentor: participant identity present, using #{a[:participant_identity].id}")
          else
            @participant_identity = SampleData::Generators::ParticipantIdentityGenerator.generate(user: @user.user)

            Rails.logger.debug("generating mentor: generated participant identity #{@participant_identity.participant_identity.id}")

            a[:participant_identity] = @participant_identity.participant_identity
          end

          if a.key?(:teacher_profile)
            Rails.logger.debug("generating mentor: teacher profile present, using #{a[:teacher_profile].id}")
          else
            @teacher_profile = SampleData::Generators::TeacherProfileGenerator.generate(user: @user.user, school: overrides[:school])

            Rails.logger.debug("generating mentor: generated teacher profile #{@teacher_profile.teacher_profile.id}")

            a[:teacher_profile] = @teacher_profile.teacher_profile
          end
        end
      end
    end
  end
end
