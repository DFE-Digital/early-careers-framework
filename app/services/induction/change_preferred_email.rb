# frozen_string_literal: true

class Induction::ChangePreferredEmail < BaseService
  def call
    Induction::ChangeInductionRecord.call(induction_record: induction_record,
                                          changes: { preferred_identity: preferred_identity })
  end

private

  attr_reader :preferred_email, :induction_record

  def initialize(induction_record:, preferred_email:)
    @induction_record = induction_record
    @preferred_email = preferred_email
  end

  def preferred_identity
    Identity::Create.call(user: induction_record.user, email: preferred_email)
  end
end
