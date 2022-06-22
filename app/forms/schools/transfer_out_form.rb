# frozen_string_literal: true

module Schools
  class TransferOutForm
    include ActiveModel::Model
    include ActiveRecord::AttributeAssignment
    include ActiveModel::Serialization

    attr_accessor :end_date

    validate :teacher_end_date

    def attributes
      {
        end_date:,
      }
    end

  private

    def teacher_end_date
      @end_date = ActiveRecord::Type::Date.new.cast(end_date)
      if @end_date.blank?
        errors.add(:end_date, I18n.t("errors.end_date.blank"))
      elsif @end_date.year.digits.length != 4
        errors.add(:end_date, I18n.t("errors.end_date.invalid"))
      end
    end
  end
end
