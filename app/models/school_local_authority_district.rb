# frozen_string_literal: true

# == Schema Information
#
# Table name: school_local_authority_districts
#
#  id                          :uuid             not null, primary key
#  end_year                    :integer
#  start_year                  :integer          not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  local_authority_district_id :uuid             not null
#  school_id                   :uuid             not null
#
# Indexes
#
#  index_school_local_authority_districts_on_school_id  (school_id)
#  index_schools_lads_on_lad_id                         (local_authority_district_id)
#
# Foreign Keys
#
#  fk_rails_...  (local_authority_district_id => local_authority_districts.id)
#  fk_rails_...  (school_id => schools.id)
#
class SchoolLocalAuthorityDistrict < ApplicationRecord
  belongs_to :school
  belongs_to :local_authority_district

  scope :latest, -> { where(end_year: nil) }
end
