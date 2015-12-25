class CreateAppointments < ActiveRecord::Migration
  def change
    create_table :appointments do |t|
      t.datetime :start
      t.datetime :end
      t.integer :patient_id
      t.integer :doctor_id
      t.references :user, index: true, foreign_key: true
      t.boolean :scheduled

      t.timestamps null: false
    end
    add_index :appointments, :start
    add_index :appointments, :patient_id
    add_index :appointments, :doctor_id
    add_index :appointments, :scheduled
  end
end
