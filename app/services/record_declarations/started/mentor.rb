# frozen_string_literal: true

module RecordDeclarations
  module Started
    class Mentor < ::RecordDeclarations::Base
      include RecordDeclarations::Mentor
      include StartedCompleted
    end
  end
end
