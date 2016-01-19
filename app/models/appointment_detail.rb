class AppointmentDetail < ActiveRecord::Base

  belongs_to :appointment

  validates :extra_details, 
            length: {minimum: 4},
            unless: ->{ self.extra_details == nil }

end
