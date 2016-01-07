class AddProposalInfoToAppointmentDetails < ActiveRecord::Migration
  def change
    add_column :appointment_details, :proposal_info, :text
  end
end
