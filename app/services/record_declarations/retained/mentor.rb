# frozen_string_literal: true

module RecordDeclarations
  module Retained
    class Mentor < ECF
      include Participants::Mentor
    end
  end
end
