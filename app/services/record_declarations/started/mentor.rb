# frozen_string_literal: true

module RecordDeclarations
  module Started
    class Mentor < ::RecordDeclarations::Base
      include Participants::Mentor
      include RecordDeclarations::ECF
    end
  end
end
