class ChangeProposalInfoToJsonbType < ActiveRecord::Migration
  def change
    remove_column :appointment_details, :proposal_info, :text
    add_column :appointment_details, :proposal_info, :jsonb

    add_index :appointment_details, :proposal_info, using: :gin
  end
end
