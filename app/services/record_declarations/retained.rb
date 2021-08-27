# frozen_string_literal: true

module RecordDeclarations
  module Retained
    extend ActiveSupport::Concern

    included do
      validates :evidence_held, presence: { message: I18n.t(:missing_evidence_held) }
      validates :evidence_held, inclusion: { in: :valid_evidence_types, message: I18n.t(:invalid_evidence_type) }, allow_blank: true
    end

    def valid_evidence_types
      self.class.valid_evidence_types
    end
  end
end
