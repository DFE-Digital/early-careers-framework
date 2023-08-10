# frozen_string_literal: true

class DQT::GetInductionRecord < ::BaseService
  def call
    dqt_record&.dig("induction")
  end

private

  attr_reader :trn

  def initialize(trn:)
    @trn = trn
  end

  def dqt_record
    @dqt_record ||= client.get_record(trn:)
  end

  def client
    @client ||= FullDQT::V3::Client.new
  end
end
