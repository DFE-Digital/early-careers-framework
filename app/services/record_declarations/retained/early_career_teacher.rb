# frozen_string_literal: true

module RecordDeclarations
  module Retained
    class EarlyCareerTeacher < ::RecordDeclarations::Base
      include RecordDeclarations::EarlyCareerTeacher
      include Retained
    end
  end
end
