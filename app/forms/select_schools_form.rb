# frozen_string_literal: true

class SelectSchoolsForm
  include ActiveModel::Model
  include ActiveModel::Serialization

  attr_accessor :school_ids
  attr_accessor :delivery_partner_id
  attr_accessor :source
end
