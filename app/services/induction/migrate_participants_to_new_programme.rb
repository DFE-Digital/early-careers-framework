# frozen_string_literal: true

class Induction::MigrateParticipantsToNewProgramme < BaseService
  def call
    ActiveRecord::Base.transaction do
      from_programme.induction_records.each do |induction_record|
        # this will duplicate the induction record and set the new programme
        Induction::ChangeInductionRecord.call(induction_record: induction_record,
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
