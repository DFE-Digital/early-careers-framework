# frozen_string_literal: true

require "pages/finance_payment_breakdown_report"
require "pages/sit_report_programme_wizard"
require "pages/lead_provider_dashboard"
require "pages/admin_support_participant_list"
require "pages/admin_support_portal"
require "pages/finance_participant_drilldown"
require "pages/finance_participant_drilldown_search"
require "pages/finance_payment_breakdown_report"
require "pages/finance_payment_breakdown_report_wizard"
require "pages/finance_portal"
require "pages/lead_provider_confirm_your_schools_wizard"
require "pages/lead_provider_dashboard"
require "pages/participant_registration_wizard"
require "pages/sit_add_participant_wizard"
require "pages/sit_induction_dashboard"
require "pages/sit_participant_details"
require "pages/sit_participants_dashboard"
require "pages/sit_transfer_participant_wizard"

module Pages

  def admin_support_participant_detail
    @admin_support_participant_detail || Pages::AdminSupportParticipantDetail.new
  end

  def admin_support_participant_list
    @admin_support_participant_list ||= Pages::AdminSupportParticipantList.new
  end

  def admin_support_portal
    @admin_support_portal ||= Pages::AdminSupportPortal.new
  end

  def finance_participant_drilldown
    @finance_participant_drilldown ||= Pages::FinanceParticipantDrilldown.new
  end

  def finance_participant_drilldown_search
    @finance_participant_drilldown_search ||= Pages::FinanceParticipantDrilldownSearch
  end

  def finance_payment_breakdown_report
    @finance_payment_breakdown_report ||= Pages::FinancePaymentBreakdownReport
  end

  def finance_payment_breakdown_report_wizard
    @finance_payment_breakdown_report_wizard ||= Pages::FinancePaymentBreakdownReportWizard.new
  end

  def finance_portal
    @finance_portal ||= Pages::FinancePortal.new
  end

  def lead_provider_confirm_your_schools_wizard
    @lead_provider_confirm_your_schools_wizard ||= Pages::LeadProviderConfirmYourSchoolsWizard.new
  end

  def lead_provider_dashboard
    @lead_provider_dashboard ||= Pages::LeadProviderDashboard.new
  end

  def participant_registration_wizard
    @participant_registration_wizard ||= Pages::ParticipantRegistrationWizard.new
  end

  def sit_add_participant_wizard
    @sit_add_participant_wizard ||= Pages::SITAddParticipantWizard.new
  end

  def sit_report_programme_wizard
    @sit_report_programme_wizard ||= Pages::SITReportProgrammeWizard.new
  end

  def sit_induction_dashboard
    @sit_induction_dashboard ||= Pages::SITInductionDashboard
  end

  def sit_participant_details
    @sit_participant_details ||= Pages::SITParticipantDetails
  end

  def sit_participants_dashboard
    @sit_participants_dashboard ||= Pages::SITParticipantsDashboard
  end

  def sit_transfer_participant_wizard
    @sit_transfer_participant_wizard ||= Pages::SITTransferParticipantWizard
  end

  module_function :finance_portal
  module_function :admin_support_participant_detail
  module_function :admin_support_participant_list
  module_function :admin_support_portal
  module_function :finance_participant_drilldown
  module_function :finance_participant_drilldown_search
  module_function :finance_payment_breakdown_report_wizard
  module_function :finance_portal
  module_function :lead_provider_confirm_your_schools_wizard
  module_function :lead_provider_dashboard
  module_function :participant_registration_wizard
  module_function :sit_add_participant_wizard
  module_function :sit_report_programme_wizard
  module_function :sit_induction_dashboard
  module_function :sit_participant_details
  module_function :sit_participants_dashboard
  module_function :sit_transfer_participant_wizard
end
