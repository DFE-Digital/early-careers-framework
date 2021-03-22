# frozen_string_literal: true

# == Schema Information
#
# Table name: district_sparsities
#
#  id                          :uuid             not null, primary key
#  end_year                    :integer
#  start_year                  :integer          not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  local_authority_district_id :uuid             not null
#
# Indexes
#
#  index_district_sparsities_on_local_authority_district_id  (local_authority_district_id)
#
# Foreign Keys
#
#  fk_rails_...  (local_authority_district_id => local_authority_districts.id)
#
class DistrictSparsity < ApplicationRecord
  belongs_to :local_authority_district

  scope :latest, -> { where(end_year: nil) }
  scope :for_year, lambda { |year|
    query = <<~SQLSNIPPET
      district_sparsities.start_year <= ?
          AND (district_sparsities.end_year > ?
              OR district_sparsities.end_year IS NULL)
    SQLSNIPPET
    where(query, year, year)
  }
end
