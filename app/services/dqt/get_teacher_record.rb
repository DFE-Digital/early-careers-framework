# frozen_string_literal: true

class DQT::GetTeacherRecord < ::BaseService
  def call
    dqt_record
  end

private

  attr_reader :date_of_birth, :nino, :trn

  def initialize(trn:, date_of_birth: nil, nino: nil)
    @trn = trn
    @date_of_birth = date_of_birth
    @nino = nino
  end

  def dqt_record
    @dqt_record ||= client.get_record(**endpoint_args)
  end

  def endpoint_args
    if v3?
      { trn:, date_of_birth: }.compact
    else
      { trn:, birthdate: date_of_birth, nino: }
    end
  end

  def client
    @client ||= v3? ? FullDQT::V3::Client.new : FullDQT::V1::Client.new
  end

  def v3?
    nino.nil?
  end
end
