# frozen_string_literal: true

module Support
  module ReportTheCorrectParticipantDetails
    extend RSpec::Matchers::DSL

    RSpec::Matchers.define :report_correct_participant_details do |participant_name|
      match do |_analytics|
        user = User.find_by(full_name: participant_name)
        raise "Could not find User for #{participant_name}" if user.nil?

        participant_profile = user.participant_profiles.first
        raise "Could not find ParticipantProfile for #{participant_name}" if participant_profile.nil?

        expect(Analytics::UpsertECFParticipantProfileJob).to have_been_enqueued.with(participant_profile:)
      end

      failure_message do |_analytics|
        "should have been #{with_description(@error, participant_name)}"
      end

      failure_message_when_negated do |_analytics|
        "should not have been #{with_description(@error, participant_name)}"
      end

      description do
        "be #{with_description(@error, participant_name)}"
      end

    private

      def with_description(_error, participant_name)
        "able to find the latest participant details for '#{participant_name}"
      end
    end
  end
end
