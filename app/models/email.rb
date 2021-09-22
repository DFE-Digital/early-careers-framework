# frozen_string_literal: true

class Email < ApplicationRecord
  class Association < ApplicationRecord
    belongs_to :email
    belongs_to :object, polymorphic: true
  end

  has_many :associations, dependent: :destroy

  UNDEFINED = Object.new
  private_constant :UNDEFINED

  scope(:associated_with, lambda do |object, as: UNDEFINED|
    association_scope = Association.where(object: object)
    association_scope = association_scope.where(name: as) unless as == UNDEFINED

    where(id: association_scope.select(:email_id))
  end)

  def associate_with(*objects, as: nil) # rubocop:disable Naming/MethodParameterName
    objects.each do |object|
      Association.create!(
        email: self,
        object: object,
        name: as,
      )
    end
  end
end
