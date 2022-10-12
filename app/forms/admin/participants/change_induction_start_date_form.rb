# frozen_string_literal: true

module Admin::Participants
  class ChangeInductionStartDateForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ::ActiveRecord::AttributeAssignment

    attribute :induction_start_date, :date

    validates :induction_start_date, presence: true

    def to_h
      { induction_start_date: }
    end
  end
end
