# frozen_string_literal: true

class Email < ApplicationRecord
  class Association < ApplicationRecord
    belongs_to :email
    belongs_to :object, polymorphic: true
  end

  self.filter_attributes += %i[to]

  has_many :associations, dependent: :destroy

  scope :associated_with, ->(object) { where(id: Association.where(object:).select(:email_id)) }
  scope :tagged_with, ->(*tags) { tags.inject(self) { |scope, tag| scope.where("? = ANY (tags)", tag) } }
  scope :failed, -> { where(status: FAILED_STATUSES) }

  FAILED_STATUSES = %w[permanent-failure temporary-failure technical-failure].freeze

  def create_association_with(*objects, as: nil)
    objects.each do |object|
      next if object.blank?

      Association.create!(
        email: self,
        object:,
        name: as || object.model_name.singular,
      )
    end
  end

  def delivered?
    status == "delivered"
  end

  def submitted?
    status == "submitted"
  end

  def failed?
    status.in? FAILED_STATUSES
  end

  def self.latest
    order(:created_at).last
  end
end
