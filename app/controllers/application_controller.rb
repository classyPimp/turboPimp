class ApplicationController < ActionController::Base
  
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include Perms::ControllerMethods
  rescue_from Perms::Exception, with: :user_not_authorized
  #AUTHENTICATION
	include SessionsHelper
	#END AUTHENTICATION

  #will paginate. To not manually type this repeating stuff
  def extract_pagination_hash(model)

    {pagination: {current_page: model.current_page,  total_pages: model.total_pages}}#,total_entries: model.total_entries,
              #offset: model.offset}}    
  end


  #Model.itearate_for_form serializes opal hash to JS formData
  #formData serialized nested arrays can't be serialized properly serverside (last item only will be in array)
  #so it iterate_for_form serialize it to simulated array the way accepts_nested_attributes_for undersatands e.g
  #{'1' => {foo: 'bar'}, 2: {foo: bar}}
  #but other xhr is serialized properly as JSON
  #so it's needed for cases when you submit files only AND OU SHOULD NORMALIZE SIMULATED array to Array
  def simulated_array_to_a(_params)
    if _params.is_a?(Hash)
      ary = []
      if /\A\d+\z/.match(_params.keys[0])
        _params.each do |k, v|
          ary << v
        end
        return ary
      end
    else
      return _params
    end 
  end

 private

	#this method is used for handling Pundit::NotAuthorizedError exception
	def user_not_authorized
		head 403
	end


end
