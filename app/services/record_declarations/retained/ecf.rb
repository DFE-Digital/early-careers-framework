# frozen_string_literal: true

module RecordDeclarations
  module Retained
    class ECF < ::RecordDeclarations::Base
      class << self
        def valid_evidence_types
          %w[training-event-attended self-study-material-completed other].freeze
        end

        def declaration_model
          ParticipantDeclaration::ECF
        end
      end

      attr_accessor :evidence_held

      validates :evidence_held, presence: { message: I18n.t(:missing_evidence_held) }
      validates :evidence_held, inclusion: { in: :valid_evidence_types, message: I18n.t(:invalid_evidence_type) }, allow_blank: true

    private

      def initialize(params:)
        super(params:)
        self.evidence_held = params[:evidence_held]
      end

      def valid_evidence_types
        self.class.valid_evidence_types
      end

      def declaration_parameters
        super.merge(evidence_held:)
      end
    end
  end
end
