# frozen_string_literal: true

class ContactSchool
  # We sent school sits an email to remind them to register for a programme in the next cohort
  # Some of these emails bounced because the emails incorrect or no longer in use
  # This is a follow up to contact schools who's SITs email has bounced.

  def sit_email_address_check(sit_email_addresses)
    sit_email_addresses.each do |email|
      user = User.find_by_email(email)

      next unless user&.induction_coordinator?

      induction_coordinator_profile = user.induction_coordinator_profile

      next unless induction_coordinator_profile.schools.any?

      user.induction_coordinator_profile.schools.each do |school|
        ParticipantMailer.with(induction_coordinator_profile:, school:).sit_contact_address_bounce.deliver_later
      end
    end
  end
end
