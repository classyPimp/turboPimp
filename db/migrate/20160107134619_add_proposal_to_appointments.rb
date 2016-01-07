class AddProposalToAppointments < ActiveRecord::Migration
  def change
    add_column :appointments, :proposal, :boolean
  end
end
