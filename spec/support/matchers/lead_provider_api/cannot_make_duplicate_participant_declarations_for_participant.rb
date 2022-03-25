# frozen_string_literal: true

module Support
  module CannotMakeDuplicateTrainingDeclarationsForParticipant
    extend RSpec::Matchers::DSL

    RSpec::Matchers.define :be_blocked_from_making_a_duplicate_training_declaration_for_the_participant do |participant_name, declaration_type|
      match do |lead_provider_name|
        user = User.find_by(full_name: participant_name)
        raise "Could not find User for #{participant_name}" if user.nil?

        participant_profile = user.participant_profiles.first
        raise "Could not find ParticipantProfile for #{participant_name}" if participant_profile.nil?

        case declaration_type
        when :started
          timestamp = participant_profile.schedule.milestones.first.start_date + 10.days
        when :retained_1
          timestamp = participant_profile.schedule.milestones.second.start_date + 10.days
        else
          puts "Unexpected declaration type \"#{declaration_type}\""
        end

        travel_to(timestamp) do
          declarations_endpoint = APIs::PostParticipantDeclarationsEndpoint.new tokens[lead_provider_name]
          declarations_endpoint.post_training_declaration participant_profile.user.id, declaration_type, timestamp - 8.days

          @text = declarations_endpoint.response

          declarations_endpoint.has_declaration_type? declaration_type.to_s
          declarations_endpoint.has_eligible_for_payment? false
          declarations_endpoint.has_voided? false
          declarations_endpoint.has_state? "ineligible"
        end
      end

      failure_message do |lead_provider_name|
        "'#{lead_provider_name}' Should have been blocked from making the declaration '#{declaration_type}' for the training of '#{participant_name}' through the ecf declarations endpoint"
      end

      failure_message_when_negated do |lead_provider_name|
        "'#{lead_provider_name}' Should not have been blocked from making the declaration '#{declaration_type}' for the training of '#{participant_name}' through the ecf declarations endpoint"
      end

      description do
        "be blocked from making the declaration #{declaration_type} for the training of '#{participant_name}' through the ecf declarations endpoint"
      end
    end
  end
end
