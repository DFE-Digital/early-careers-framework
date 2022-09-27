# frozen_string_literal: true

module AppropriateBodies
  class ChooseOrganisationForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :user
    attribute :appropriate_body_id

    validates :appropriate_body_id, inclusion: { in: :valid_ids }

    def appropriate_body_options
      @appropriate_body_options ||= user.appropriate_bodies.each_with_object({}) do |ab, options|
        options[ab.id] = ab.name
      end
    end

    def appropriate_body
      return if appropriate_body_id.blank?

      user.appropriate_bodies.find(appropriate_body_id)
    end

    def only_one
      return false if user.appropriate_bodies.count > 1

      self.appropriate_body_id = user.appropriate_bodies.first.id
      true
    end

  private

    def valid_ids
      appropriate_body_options.keys
    end
  end
end
