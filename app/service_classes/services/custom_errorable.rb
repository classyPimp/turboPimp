module Services
  module CustomErrorable

    def self.included(base)
      base.validate(:check_for_custom_errors)
    end


    def custom_errors
      @custom_errors ||= {}
    end

    def check_for_custom_errors
      unless @custom_errors && custom_errors.empty?
        custom_errors.each do |k, v|
          errors[k] = v
        end
      end  
    end

    def clear_custom_errors
      @custom_errors = {}
    end 

  end
end