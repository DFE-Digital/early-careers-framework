# frozen_string_literal: true

module Admin
  module Schools
    class RelationshipComponent < ViewComponent::Base
      attr_accessor :relationship, :school, :school_cohort, :participants, :superuser

      def initialize(relationship:, school:, school_cohort:, superuser:, participants: nil)
        @relationship = relationship
        @school = school
        @school_cohort = school_cohort
        @participants = participants || relationship.induction_programmes.flat_map(&:participant_profiles)
        @superuser = superuser
      end

      def challenge_href
        return unless superuser

        govuk_link_to("Challenge relationship", new_admin_school_partnership_challenge_partnership_path(school_cohort.school, relationship))
      end

      def delivery_partner_name
        relationship.delivery_partner.name
      end

      def participants_profile_links
        participants.map { |p| helpers.govuk_link_to(p.full_name, admin_participant_path(p)) }
      end
    end
  end
end
