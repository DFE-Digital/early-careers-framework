# frozen_string_literal: true

module RecordDeclarations
  module Started
    class NPQ < ::RecordDeclarations::Base
      include RecordDeclarations::NPQ
      include StartedCompleted
    end
  end
end
