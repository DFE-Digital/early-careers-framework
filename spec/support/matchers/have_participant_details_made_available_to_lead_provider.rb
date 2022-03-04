# frozen_string_literal: true

module Support
  module HaveParticipantDetailsMadeAvailableToLeadProvider
    extend RSpec::Matchers::DSL

    RSpec::Matchers.define :have_their_details_made_available_to do |lead_provider_name|
      match do |participant_name|
        @error = nil
        @expected = nil
        @value = nil

        participant = participants[participant_name]

        declarations_endpoint = APIs::ECFParticipantsEndpoint.new(tokens[lead_provider_name])
        unless declarations_endpoint.can_access_participant_details?(participant)
          attributes = declarations_endpoint.get_participant_details(participant)

          if attributes.nil?
            @error = :attributes
          else
            unless attributes["email"] == participant.user.email
              @error = :email
              @expected = participant.user.email
              @value = attributes["email"]
            end
            unless attributes["full_name"] == participant.user.full_name
              @error = :full_name
              @expected = participant.user.full_name
              @value = attributes["full_name"]
            end
            unless attributes["school_urn"] == participant.school.urn
              @error = :school_urn
              @expected = participant.school.urn
              @value = attributes["school_urn"]
            end
            unless attributes["participant_type"] == participant.participant_type.to_s
              @error = :participant_type
              @expected = participant.participant_type
              @value = attributes["participant_type"]
            end
            unless attributes["status"] == participant.status
              @error = :status
              @expected = participant.status
              @value = attributes["status"]
            end
            unless attributes["training_status"] == participant.training_status
              @error = :training_status
              @expected = participant.training_status
              @value = attributes["training_status"]
            end
          end
        end

        @error.nil?
      end

      failure_message do |_participant_name|
        case @error
        when :attributes
          "Should have received some details in the response"
        else
          "Should have got [#{@expected}] but got [#{@value}] for [#{@error}] when #{lead_provider_name} calls ecf participants endpoint"
        end
      end

      failure_message_when_negated do |_participant_name|
        case @error
        when :attributes
          "Should not have received details in the response"
        else
          "Should not have got [#{@value}] for [#{@error}] when #{lead_provider_name} calls ecf participants endpoint"
        end
      end

      description do
        "have their details made available to #{lead_provider_name}"
      end
    end
  end
end
