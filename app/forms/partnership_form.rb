# frozen_string_literal: true

class PartnershipForm
  include ActiveModel::Model

  attr_accessor :schools

  # Needed to create the checkbox
  def select_all; end
end
