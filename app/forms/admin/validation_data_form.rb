# frozen_string_literal: true

class Admin::ValidationDataForm
  include ActiveModel::Model
  include ActiveRecord::AttributeAssignment
  include ActiveModel::Serialization

  attr_accessor :participant_profile_id, :full_name, :trn, :date_of_birth, :nino

  validates :full_name, presence: true, on: :full_name
  validates :trn, presence: true, teacher_reference_number: true, on: :trn
  validate :date_of_birth_is_valid, on: :date_of_birth
  validates :nino, national_insurance_number: true, allow_blank: true, on: :nino

  def participant_name
    participant_profile.user.full_name
  end

  def formatted_nino
    NationalInsuranceNumber.new(@nino).formatted_nino
  end

private

  def participant_profile
    @participant_profile ||= ParticipantProfile::ECF.find(participant_profile_id)
  end

  def date_of_birth_is_valid
    @date_of_birth = ActiveRecord::Type::Date.new.cast(date_of_birth)
    if @date_of_birth.blank?
      errors.add(:date_of_birth, :blank)
    elsif @date_of_birth > Time.zone.now
      errors.add(:date_of_birth, :in_future)
    elsif !@date_of_birth.between?(Date.new(1900, 1, 1), Date.current - 18.years)
      errors.add(:date_of_birth, :invalid)
    elsif @date_of_birth.year.digits.length != 4
      errors.add(:date_of_birth, :invalid)
    end
  rescue ArgumentError
    errors.add(:date_of_birth, :invalid)
  end
end
