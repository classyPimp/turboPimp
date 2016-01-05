class AppointmentAvailability < ActiveRecord::Base
  
  belongs_to :user
  #================= PUBSUBBUS CLASS LEVEL
  #invoked from on_create callback from Appointment
  #finds or creates appointment
  #map contains stringified json which shall be sen to client and serialized there and used as needed

  def self.on_appointment_created(appointment)
    
    a_a = self.where(for_date: appointment.start_date.strftime('%Y-%m-%d'), user_id: appointment.doctor_id).first_or_create
    if a_a.map.blank?
      map = []
    else
      map = JSON.parse(a_a.map)
    end

    start_date = appointment.start_date.to_formatted_s(:iso8601)
    end_date = appointment.end_date.to_formatted_s(:iso8601)

    map << start_date
    map << end_date

    a_a.update_attributes map: "#{map.to_json}", user_id: appointment.doctor_id, for_date: appointment.start_date.strftime('%Y-%m-%d')
    a_a.save
  end

  def self.on_appointment_destroyed(appointment)
    a_a = self.where(for_date: appointment.start_date.strftime('%Y-%m-%d'), user_id: appointment.doctor_id).first_or_create
    
    return true if a_a.map.blank?

    map = JSON.parse(a_a.map)

    start_date = appointment.start_date.to_formatted_s(:iso8601)
    end_date = appointment.end_date.to_formatted_s(:iso8601)
    map = map.each_slice(2).to_a
    map.delete_if do |date|
      date[0] == start_date && date[1] == end_date
    end
    a_a.update map: "#{map.flatten.to_json}", user_id: appointment.doctor_id, for_date: appointment.start_date.strftime('%Y-%m-%d')
  end

  def self.on_appointment_updated(appointment, old_values)
    a_a = self.where(for_date: appointment.start_date.strftime('%Y-%m-%d'), user_id: appointment.doctor_id).first_or_create
    
    return true if a_a.map.blank?

    map = JSON.parse(a_a.map)

    start_date = appointment.start_date.to_formatted_s(:iso8601)
    end_date = appointment.end_date.to_formatted_s(:iso8601)

    old_values[0] = old_values[0] || start_date
    old_values[1] = old_values[1] || end_date

    map = map.each_slice(2).to_a
    map.each do |pair|
      if pair[0] == old_values[0] && pair[1] == old_values[1]
        date = [start_date, end_date] and break
      end
    end
    a_a.update map: "#{map.flatten.to_json}", user_id: appointment.doctor_id, for_date: appointment.start_date.strftime('%Y-%m-%d')
  end


  include Services::PubSubBus
  implemented_channels class: [:on_appointment_created, :on_appointment_destroyed, :on_appointment_updated]
#=============END PUBSUBBUS
end
