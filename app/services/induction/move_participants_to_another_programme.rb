# frozen_string_literal: true

class Induction::MoveParticipantsToAnotherProgramme < BaseService
  def call
    ActiveRecord::Base.transaction do
      from_programme.active_induction_records.each do |induction_record|
        Induction::ChangeInductionRecord.call(induction_record:,
                                              changes: { induction_programme_id: to_programme.id })
      end
    end
  end

private

  attr_reader :from_programme, :to_programme

  def initialize(from_programme:, to_programme:)
    @from_programme = from_programme
    @to_programme = to_programme
  end
end
