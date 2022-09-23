# frozen_string_literal: true

module DeliveryPartners
  class ChooseOrganisationForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :user
    attribute :delivery_partner_id

    validates :delivery_partner_id, inclusion: { in: :valid_ids }

    def delivery_partner_options
      @delivery_partner_options ||= user.delivery_partners.each_with_object({}) do |ab, sum|
        sum[ab.id] = ab.name
      end
    end

    def delivery_partner
      return if delivery_partner_id.blank?

      user.delivery_partners.find(delivery_partner_id)
    end

    def only_one
      return false if user.delivery_partners.count > 1

      self.delivery_partner_id = user.delivery_partners.first.id
      true
    end

  private

    def valid_ids
      delivery_partner_options.keys
    end
  end
end
