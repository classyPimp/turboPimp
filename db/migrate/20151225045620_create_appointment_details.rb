class CreateAppointmentDetails < ActiveRecord::Migration
  def change
    create_table :appointment_details do |t|
      t.references :appointment, index: true, foreign_key: true
      t.text :note
      t.text :extra_details

      t.timestamps null: false
    end
  end
end
