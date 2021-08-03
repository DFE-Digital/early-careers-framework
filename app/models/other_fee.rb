# frozen_string_literal: true

class OtherFee
  include ActiveModel::Model
  attr_accessor :name, :participants, :per_participant, :subtotal

  def participants=(value)
    @participants=value.to_i
  end

  def initialize(params)
    self.name=params[0]
    params[1].each do |param, value|
      send("#{param}=", value)
    end
  end
end
