# frozen_string_literal: true

class MentorProfileDeclaration < ApplicationRecord
  belongs_to :mentor_profile

  scope :unique_id, -> { select(:mentor_profile_id).distinct }
  scope :uplift, -> { joins(:mentor_profile).merge(MentorProfile.uplift) }
end
