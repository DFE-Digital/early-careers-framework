# frozen_string_literal: true

module RecordDeclarations
  module Started
    class EarlyCareerTeacher < ::RecordDeclarations::Base
      include RecordDeclarations::EarlyCareerTeacher
      include StartedCompleted
    end
  end
end
