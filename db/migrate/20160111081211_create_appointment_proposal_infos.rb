class CreateAppointmentProposalInfos < ActiveRecord::Migration
  def change
    create_table :appointment_proposal_infos do |t|
      t.references :appointment, index: true, foreign_key: true
      t.boolean :primary
      t.integer :doctor_id
      t.datetime :date_from
      t.datetime :date_to
      t.datetime :anytime_for_date

      t.timestamps null: false
    end
    add_index :appointment_proposal_infos, :doctor_id
  end
end
