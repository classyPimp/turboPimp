#TRIED TO REFACTOR APPOINTMNET AVAILABILITY ON CHANGES OF APPOINTMNET
#STOPPED HALF ROAD AND DECIDED TO GO EXCLUDING APPOINTMENT AVAILABILITY
#LEAVING JUST IN CASE, CHECK AND DELETE LATER 
# class ModelHelpers::AppointmentAvailability::AppointmentHelper

#   def initialize(action, appointment)
    
#     @action = action
#     @appointment = appointment

#     @start_date = @appointment.start_date
#     @end_date = @appointment.end_date

#     @start_date_strf = @start_date.strftime('%Y-%m-%d')

#     @user_id = @appointment.doctor_id

#     if @action == :on_create
#       initialize_on_create
#     elsif action == :on_update
#       initialize_on_update
#     elsif action == :on_destroy
#       initialize_on_destroy
#     end

#   end

#   def initialize_on_create

#     find_appointment_availability_by_start_date( first_or_create: true )

#     prepare_map

#     push_to_map

#     map_to_json!

#     persist_on_create

#   end

#   def initialize_on_destroy
    
#     find_appointment_availability_by_start_date( first_or_create: false )

#     prepare_map

#     set_current_iso_dates_ivars

#     clear_date_pair_from_map

#     map_flatten!

#     map_to_json!

#     persist_on_destroy

#   end

#   def initialize_on_updated
    
#     set_old_values_ivars

#     find_appointment_availability_by_old_start_date

#     prepare_map

#     set_current_iso_dates_ivars

#     set_old_iso_dates_ivars

#     #current_and_old_start_days_differ?

#   end

#   def set_old_iso_dates_ivars
#     @old_start_date_iso = old_start_date.to_formatted_s(:iso8601) || iso_start_date
#     @old_end_date_iso = old_end_date.to_formatted_s(:iso8601) || iso_end_date
#   end

#   def current_and_old_start_days_differ?

#     @start_date != @old_start_date
  
#   end

#   def set_old_values_ivars
    
#     old_values = appointment.changes_of_start_date_and_end_date

#     @old_start_date = old_values[0] ? Time.parse(old_values[0]) : @start_date
#     @old_end_date = old_values[1] ? Time.parse(old_values[1]) : @end_date

#   end

#   def persist_on_destroy
#     @existing_a_a.attributes = {map: "#{@map}", user_id: @user_id, for_date: @start_date_strf}
#     @existing_a_a.save
#   end

#   def clear_date_pair_from_map

#     @map = @map.each_slice(2).to_a

#     @map.delete_if do |date|
#       date[0] == @start_date && date[1] == @end_date
#     end

#   end

#   def map_flatten!
    
#     @map = @map.flatten

#   end

#   def map_to_json!
#     @map = @map.to_json
#   end

#   def set_current_iso_dates_ivars

#     @start_date_iso = @start_date.to_formatted_s(:iso8601)
#     @end_date_iso = @end_date_iso.to_formatted_s(:iso8601)

#   end

#   def find_appointment_availability_by_start_date(first_or_create:)
#     a_a = ::AppointmentAvailability.where(for_date: @start_date_strf, user_id: @user_id)
#     if first_or_create
#       a_a = a_a.first_or_create
#     else
#       a_a = a_a.first
#     end
#     @existing_a_a = a_a
#   end

#   def find_appointment_availability_by_old_start_date
#     a_a = ::AppointmentAvailability.where(for_date: @old_start_date.strftime('%Y-%m-%d'), user_id: @user_id)
#     @existing_a_a = a_a.first
#   end

#   def prepare_map
#     if @existing_a_a.map.blank?
#       @map = []
#     else
#       @map = JSON.parse(a_a.map)
#     end
#   end

#   def push_to_map
#     @map << @start_date
#     @map << @end_date
#   end

#   def persist_on_create
#     @existing_a_a.attributes = {map: "#{@map}", user_id: @user_id, for_date: @start_date_strf}
#     @existing_a_a.save
#   end

# end