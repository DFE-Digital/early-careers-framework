# frozen_string_literal: true

class ProfileDeclaration < ApplicationRecord
  delegated_type :declarable, types: %w[EarlyCareerTeacherProfileDeclaration MentorProfileDeclaration]
  belongs_to :participant_declaration
  belongs_to :lead_provider
end
