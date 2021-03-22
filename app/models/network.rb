# frozen_string_literal: true

# == Schema Information
#
# Table name: networks
#
#  id                      :uuid             not null, primary key
#  group_type              :string
#  group_type_code         :string
#  group_uid               :string
#  name                    :string           not null
#  secondary_contact_email :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  group_id                :string
#
class Network < ApplicationRecord
  has_many :schools
end
