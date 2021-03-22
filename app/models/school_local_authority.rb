# frozen_string_literal: true

# == Schema Information
#
# Table name: school_local_authorities
#
#  id                 :uuid             not null, primary key
#  end_year           :integer
#  start_year         :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  local_authority_id :uuid             not null
#  school_id          :uuid             not null
#
# Indexes
#
#  index_school_local_authorities_on_local_authority_id  (local_authority_id)
#  index_school_local_authorities_on_school_id           (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (local_authority_id => local_authorities.id)
#  fk_rails_...  (school_id => schools.id)
#
class SchoolLocalAuthority < ApplicationRecord
  belongs_to :school
  belongs_to :local_authority

  scope :latest, -> { where(end_year: nil) }
end
