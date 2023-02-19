# frozen_string_literal: true

class WizardStep
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  attr_accessor :wizard

  def self.permitted_params
    []
  end

  def previous_step
    raise NotImplementedError
  end

  def next_step
    raise NotImplementedError
  end

  def before_render; end
  def after_save; end
  def after_render; end

  def attributes
    self.class.permitted_params.index_with do |key|
      public_send(key)
    end
  end
end
