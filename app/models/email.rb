# frozen_string_literal: true

class Email < ApplicationRecord
  class Association < ApplicationRecord
    belongs_to :email
    belongs_to :object, polymorphic: true
  end

  has_many :associations, dependent: :destroy

  scope :associated_with, ->(object) { where(id: Association.where(object: object).select(:email_id)) }
  scope :tagged_with, ->(*tags) { tags.inject(self) { |scope, tag| scope.where("? = ANY (tags)", tag) } }

  def create_association_with(*objects, as: nil) # rubocop:disable Naming/MethodParameterName
    objects.each do |object|
      Association.create!(
        email: self,
        object: object,
        name: (as || object.model_name.singular),
      )
    end
  end
end
