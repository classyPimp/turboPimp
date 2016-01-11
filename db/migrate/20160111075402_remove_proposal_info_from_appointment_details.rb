class RemoveProposalInfoFromAppointmentDetails < ActiveRecord::Migration
  def change
    remove_column :appointment_details, :proposal_info, :jsonb
  end
end
