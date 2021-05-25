class ContractEventPaymentCalculator
  include InitializeWithConfig

  def call(total_participants:, event_type:)
    payment_calculator.call(config, total_participants:total_participants, event_type: event_type )
  end

  def default_config
    {
      payment_calculator: ::PaymentCalculator::Ecf::PaymentCalculation
    }
  end
end
