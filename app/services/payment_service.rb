# frozen_string_literal: true

class PaymentService
  def generate_html(payment)
    template = ERB.new(File.read("app/views/payments/payments.html.erb"))
    template.result(binding)
  end
end
