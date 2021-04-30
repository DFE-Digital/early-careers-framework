# frozen_string_literal: true

class ConfirmSchoolsForm
  include ActiveModel::Model
  include ActiveModel::Serialization

  attr_accessor :school_ids, :delivery_partner_id, :source, :cohort
end
