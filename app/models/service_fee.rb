# frozen_string_literal: true

class ServiceFee
  include ActiveModel::Model
  attr_accessor :band, :participants, :per_participant, :monthly

  def initialize(params)
    params.each do |param, value|
      send("#{param}=", value)
    end
  end
end
