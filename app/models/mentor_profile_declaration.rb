# frozen_string_literal: true

class MentorProfileDeclaration < ApplicationRecord
  belongs_to :mentor_profile
  include Declarable

  scope :uplift, -> { joins(:mentor_profile).merge(MentorProfile.uplift) }
end
