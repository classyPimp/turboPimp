class Appointment < Model

  attributes :id, :start_date, :end_date, :patient_id, :doctor_id, :user_id, :scheduled, :proposal
  has_one :appointment_detail, :patient
  has_many :appointment_proposal_infos
  accepts_nested_attributes_for :appointment_detail, :appointment_proposal_infos


  route "Show", get: "appointments/:id"

  route "update", {put: "appointments/:id"}, {defaults: [:id]}

  route "create", post: "appointments"

  route "Index", get: "appointments"

  route "Proposal_index", get: "appointments/proposal_index"
  
  route "Availabilities_index", get: "appointments/availabilities"

  def self.responses_on_proposal_index(r)
     self.responses_on_index(r)
  end

  route "destroy", {delete: "appointments/:id"}, {defaults: [:id]} 

  route "Edit", {get: "appointments/:id/edit"}

  route 'schedule_appointment', {post: 'appointments/schedule_from_proposal'}

  def on_before_schedule_appointment(r)
    on_before_update(r)
  end

  def responses_on_schedule_appointment(r)
    responses_on_update(r)
  end

  def validate_time_part_from
    unless x = Moment.new("#{self.attributes[:time_part_from]}", "HHmm").isValid()
      add_error :time_part_from, "should provide hours and minutes in valid format like '10 30' or '1030' or '10:30' or '10.30' or '10 30'"
    end
  end

  def validate_time_part_to
    unless x = Moment.new("#{self.attributes[:time_part_to]}", "HHmm").isValid()
      add_error :time_part_to, "should provide hours and minutes in valid format like '10 30' or '1030' or '10:30' or '10.30' or '10 30'"
    end
  end

  def validate_start_date
    unless (x = Moment.new(self.start_date)).isValid()
      add_error :start_date, "should provide a valid date"
    end
    unless end_date == nil
      unless x.isValid && (x.isBefore(Moment.new(self.end_date)))
        add_error :start_date, "start date should be before end date"
      end
    end
  end

  def validate_end_date
    unless Moment.new(self.end_date).isValid()
      add_error :end_date, "should provide a valid date"
    end
  end

  def validate_patient_id
    unless patient_id && patient_id.to_i.is_a?(Integer)
      add_error :patient_id, "you should choose a patient"
    end
  end  

end