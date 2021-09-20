# frozen_string_literal: true

class MockParticipantValidationService
  attr_reader :trn, :nino, :full_name, :date_of_birth, :config

  def self.validate(trn:, full_name:, date_of_birth:, nino: nil, config: {})
    new(
      trn: trn,
      full_name: full_name,
      date_of_birth: date_of_birth,
      nino: nino,
      config: config,
    ).validate
  end

  def initialize(trn:, full_name:, date_of_birth:, nino: nil, config: {})
    @trn = trn
    @full_name = full_name
    @date_of_birth = date_of_birth
    @nino = nino
    @config = config
  end

  def validate
    return if trn.to_i.odd?

    {
      trn: trn,
      qts: rand(40.years.ago..3.years.ago),
      active_alert: false,
      previous_participation: false,
      previous_induction: false,
    }
  end
end
