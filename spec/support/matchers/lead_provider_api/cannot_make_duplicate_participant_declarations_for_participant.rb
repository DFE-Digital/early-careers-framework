# frozen_string_literal: true

module Support
  module CannotMakeDuplicateTrainingDeclarationsForParticipant
    extend RSpec::Matchers::DSL

    RSpec::Matchers.define :be_blocked_from_making_a_duplicate_training_declaration_for_the_participant do |participant_name, declaration_type|
      match do |lead_provider_name|
        @error = nil
        @expected = nil
        @value = nil

        declarations_endpoint = APIs::ParticipantDeclarationsEndpoint.new tokens[lead_provider_name]

        user = User.find_by(full_name: participant_name)
        raise "Could not find User for #{participant_name}" if user.nil?

        participant = user.participant_profiles.first
        raise "Could not find ParticipantProfile for #{participant_name}" if participant.nil?

        case declaration_type
        when :started
          timestamp = participant.schedule.milestones.first.start_date + 10.days
          declaration_date = timestamp - 8.days
        when :retained_1
          timestamp = participant.schedule.milestones.second.start_date + 10.days
          declaration_date = timestamp - 8.days
        else
          puts "declaration type was actually #{declaration_type}"
        end

        response = nil
        travel_to(timestamp) do
          response = declarations_endpoint.post_training_declaration participant, declaration_type, declaration_date
        end

        if response.nil?
          @error = :response
        else
          unless response["declaration_type"] == declaration_type.to_s
            @error = :declaration_type
            @expected = declaration_type
            @value = response["declaration_type"]
          end
          unless response["eligible_for_payment"] == false
            @error = :eligible_for_payment
            @expected = false
            @value = response["eligible_for_payment"]
          end
          unless response["voided"] == false
            @error = :voided
            @expected = false
            @value = response["voided"]
          end
          unless response["state"] == :ineligible.to_s
            @error = :state
            @expected = :ineligible
            @value = response["state"]
          end
        end

        @error.nil?
      end

      failure_message do |lead_provider_name|
        case @error
        when :attributes
          "'#{lead_provider_name}' Should have been blocked from making the declaration '#{declaration_type}' for the training of '#{participant_name}' through the ecf declarations endpoint"
        else
          "'#{lead_provider_name}' Should have been blocked from making the declaration '#{declaration_type}' but got [#{@value}] instead of [#{@expected}] for [#{@error}] through the ecf declarations endpoint"
        end
      end

      failure_message_when_negated do |lead_provider_name|
        case @error
        when :attributes
          "'#{lead_provider_name}' Should not have been blocked from making the declaration '#{declaration_type}' for the training of '#{participant_name}' through the ecf declarations endpoint"
        else
          "'#{lead_provider_name}' Should not have been blocked from making the declaration '#{declaration_type}' but got [#{@value}] for [#{@error}] through the ecf declarations endpoint"
        end
      end

      description do
        "be blocked from making the declaration #{declaration_type} for the training of '#{participant_name}' through the ecf declarations endpoint"
      end
    end
  end
end
