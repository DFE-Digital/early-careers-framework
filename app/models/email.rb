# frozen_string_literal: true

class Email < ApplicationRecord
  class Association < ApplicationRecord
    belongs_to :email
    belongs_to :object, polymorphic: true
  end

  has_many :associations, dependent: :destroy

  scope :associated_with, ->(object) { where(id: Association.where(object: object).select(:email_id)) }
  scope :tagged_with, ->(*tags) { tags.inject(self) { |scope, tag| scope.where("? = ANY (tags)", tag) } }

  FAILED_STATUSES = %w[permanent-failure temporary-failure technical-failure].freeze

  def create_association_with(*objects, as: nil) # rubocop:disable Naming/MethodParameterName
    objects.each do |object|
      Association.create!(
        email: self,
        object: object,
        name: (as || object.model_name.singular),
      )
    end
  end

  def delivered?
    status == "delivered"
  end

  def failed?
    status.in? FAILED_STATUSES
  end

  def self.latest
    order(:created_at).last
  end

  def actioned!(at: Time.zone.now, override: false)
    return if !override && actioned_at.present?

    update_column(:actioned_at, at)
  end
end
