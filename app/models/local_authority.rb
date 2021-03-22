# frozen_string_literal: true

# == Schema Information
#
# Table name: local_authorities
#
#  id         :uuid             not null, primary key
#  code       :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_local_authorities_on_code  (code) UNIQUE
#
class LocalAuthority < ApplicationRecord
  has_many :school_local_authorities
  has_many :schools, through: :school_local_authorities
end
