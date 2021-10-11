# frozen_string_literal: true

module RecordDeclarations
  module Started
    class NPQ < ::RecordDeclarations::Base
      include Participants::NPQ
      include RecordDeclarations::NPQ
    end
  end
end
