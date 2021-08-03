# frozen_string_literal: true

module RecordDeclarations
  module Retained
    extend ActiveSupport::Concern

    included do
      validates :evidence_held, presence: { message: "The property '#/evidence_held' must be present" }
    end
  end
end
