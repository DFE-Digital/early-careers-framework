# frozen_string_literal: true

class EmailDecorator < SimpleDelegator
  attr_reader :email

  def initialize(email)
    @email = email
  end

  def to_s
    partial_email
  end

private

  def partial_email
    name, domain = @email.split("@")
    if name.length <= 2
      "#{"*" * name.length}@#{domain}"
    elsif name.length == 3
      "#{name[0]}**@#{domain}"
    else
      "#{name[0]}#{("*" * (name.length - 2))}#{name[-1]}@#{domain}"
    end
  end
end
