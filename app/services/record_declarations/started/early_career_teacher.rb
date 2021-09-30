# frozen_string_literal: true

module RecordDeclarations
  module Started
    class EarlyCareerTeacher < ::RecordDeclarations::Base
      include Participants::EarlyCareerTeacher
      include RecordDeclarations::ECF
    end
  end
end
