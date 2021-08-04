# frozen_string_literal: true

module RecordDeclarations
  module Retained
    class Mentor < ::RecordDeclarations::Base
      include RecordDeclarations::Mentor
      include Retained
    end
  end
end
