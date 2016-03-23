class AppointmentAvailability < ActiveRecord::Base  
  
  belongs_to :user
  #DEPRECATED 
  #TODO DELETE
  #LEAVING JUST IN CASE 
  #NOT USED, previously when each appointment was either added updated or deleted appoinymentavailability for start date in appointment was also affected
  #this model was used to give some feed on appointmnet availability for schedule browsing for patient to show the gaps where they can propose an appointment
  #but later decided to get rid of this messy stuff, where needed it just grabs the appointments themself and on client those gaps are built and rendered.
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

    a_a.attributes = {map: "#{map.to_json}", user_id: appointment.doctor_id, for_date: appointment.start_date.strftime('%Y-%m-%d')}
    
    a_a.save
  end
  #invoked from on_create callback from Appointment
  #finds or creates appointment
  #map contains stringified json which shall be sen to client and serialized there and used as needed
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
    a_a.attributes = {map: "#{map.flatten.to_json}", user_id: appointment.doctor_id, for_date: appointment.start_date.strftime('%Y-%m-%d')}
    a_a.save
  end
  #invoked from on_create callback from Appointment
  #finds or creates appointment
  #map contains stringified json which shall be sen to client and serialized there and used as needed
  def self.on_appointment_updated(appointment)
    
    old_values = appointment.changes_of_start_date_and_end_date

    old_start_date = old_values[0] ? Time.parse(old_values[0]) : false
    old_end_date = old_values[1] ? Time.parse(old_values[1]) : false

    start_date = appointment.start_date
    end_date = appointment.end_date

    another_day = false
    if old_start_date && ( old_start_date.strftime('%Y-%m-%d') != start_date.strftime('%Y-%m-%d') )
      antoher_day = true
    end

    a_a = self.where(for_date: old_start_date.strftime('%Y-%m-%d'), user_id: appointment.doctor_id).first

    map = JSON.parse(a_a.map)

    iso_start_date = appointment.start_date.to_formatted_s(:iso8601)
    iso_end_date = appointment.end_date.to_formatted_s(:iso8601)

    iso_old_start_date = old_start_date.to_formatted_s(:iso8601) || iso_start_date
    iso_old_end_date = old_end_date.to_formatted_s(:iso8601) || iso_end_date

    map = map.each_slice(2).to_a

    unless another_day

      map.each do |pair|
        if pair[0] == iso_old_start_date && pair[1] == iso_old_end_date
          pair[0] = iso_start_date
          pair[1] = iso_end_date
          break
        end
      end

    else

      map.delete_if do |pair|
        if pair[0] == iso_old_start_date && pair[1] == iso_old_end_date
          true
        end
      end

      #.on_appointment_destroyed
      new_a_a = self.where(for_date: appointment.start_date.strftime('%Y-%m-%d'), user_id: appointment.doctor_id).first_or_create
      if new_a_a.map.blank?
        map = []
      else
        map = JSON.parse(a_a.map)
      end

      start_date = appointment.start_date.to_formatted_s(:iso8601)
      end_date = appointment.end_date.to_formatted_s(:iso8601)

      map << start_date
      map << end_date

      new_a_a.attributes = {map: "#{map.to_json}", user_id: appointment.doctor_id, for_date: appointment.start_date.strftime('%Y-%m-%d')}
      
      a_a.save

    end

    a_a.attributes = {map: "#{map.flatten.to_json}", user_id: appointment.doctor_id, for_date: appointment.start_date.strftime('%Y-%m-%d')}
    
    a_a.save
  
  end


  extend Services::PubSubBus::Subscriber
  implemented_channels class: [:on_appointment_created, :on_appointment_destroyed, :on_appointment_updated]
#=============END PUBSUBBUS
end
