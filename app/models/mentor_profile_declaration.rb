# frozen_string_literal: true

class MentorProfileDeclaration < ApplicationRecord
  belongs_to :mentor_profile
  include Declarable
end
