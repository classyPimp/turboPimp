module Perms
  class PatientRules < Perms::Base

    def patients_feed
      if @current_user && @current_user.has_role?(:doctor)
        true
      end
    end

  end
end