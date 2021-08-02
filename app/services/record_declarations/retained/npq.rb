# frozen_string_literal: true

module RecordDeclarations
  module Retained
    class NPQ < ::RecordDeclarations::Base
      include RecordDeclarations::NPQ
      include Retained
    end
  end
end
