# frozen_string_literal: true

class OutputPayment
  include ActiveModel::Model
  attr_accessor :band, :participants, :per_participant, :subtotal

  def initialize(params)
    params.each do |param, value|
      send("#{param}=", value)
    end
  end
end
