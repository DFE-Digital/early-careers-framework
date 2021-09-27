# frozen_string_literal: true

require "abstract_interface"

module RecordDeclarations
  module Retained
    class Base < ::RecordDeclarations::Base
      attr_accessor :evidence_held

      validates :evidence_held, presence: { message: I18n.t(:missing_evidence_held) }
      validates :evidence_held, inclusion: { in: :valid_evidence_types, message: I18n.t(:invalid_evidence_type) }, allow_blank: true

    private

      def initialize(params:)
        super(params: params)
        self.evidence_held = params[:evidence_held]
      end

      def valid_evidence_types
        self.class.valid_evidence_types
      end

      def create_declaration_attempt!
        ParticipantDeclarationAttempt.create!(
          course_identifier: course_identifier,
          declaration_date: declaration_date,
          declaration_type: declaration_type,
          cpd_lead_provider: cpd_lead_provider,
          user: user,
          evidence_held: evidence_held,
        )
      end

      def find_or_create_record!
        ActiveRecord::Base.transaction do
          self.class.declaration_model.find_or_create_by!(
            course_identifier: course_identifier,
            declaration_date: declaration_date,
            declaration_type: declaration_type,
            cpd_lead_provider: cpd_lead_provider,
            user: user,
            evidence_held: evidence_held,
          ) do |participant_declaration|
            profile_declaration = ProfileDeclaration.create!(
              participant_declaration: participant_declaration,
              participant_profile: user_profile,
            )
            profile_declaration.update!(payable: participant_declaration.currently_payable)
          end
        end
      end
    end
  end
end
