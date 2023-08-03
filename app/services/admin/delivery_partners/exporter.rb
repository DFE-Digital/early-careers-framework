# frozen_string_literal: true

require "csv"

module Admin
  module DeliveryPartners
    class Exporter
      COLUMN_HEADINGS = [
        "Full name",
        "Email",
        "Delivery Partner ID",
        "Delivery Partner Name",
      ].freeze

      def csv
        CSV.generate do |csv|
          csv << COLUMN_HEADINGS
          delivery_partner_profiles.each { |dpp| csv << row(dpp) }
        end
      end

    private

      def row(delivery_partner_profile)
        [
          delivery_partner_profile.user.full_name,
          delivery_partner_profile.user.email,
          delivery_partner_profile.delivery_partner.id,
          delivery_partner_profile.delivery_partner.name,
        ]
      end

      def delivery_partner_profiles
        @delivery_partner_profiles ||= DeliveryPartnerProfile
          .includes(:user, :delivery_partner)
          .order("users.full_name")
      end
    end
  end
end
