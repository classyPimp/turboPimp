require 'net/http'
require 'uri'

class FakerController < ApplicationController

	def home
    if current_user
      @current_user = current_user.as_json(only: [:id, :email, :registered], roles: current_user.general_roles_as_json)
    else
      @current_user = nil
    end
  end
    			

  def console
   raise "hello there!"   
  end

	def test
    
	end

  def test_prerender
    def fetch(uri_str, limit = 10)
      # You should choose a better exception.
      raise ArgumentError, 'too many HTTP redirects' if limit == 0

      response = Net::HTTP.get_response(URI(uri_str))

      case response
      when Net::HTTPSuccess then
        response
      when Net::HTTPRedirection then
        location = response['location']
        warn "redirected to #{location}"
        fetch(location, limit - 1)
      else
        response.value
      end
    end

    x = fetch('http://localhost:8888/')
    
    render inline: x.body


  end

  def restricted_asset
    if current_user
      send_file Rails.root + "app/assets/javascripts/foo.js.rb", type: "application/javascript"
    else
      head 403
    end
  end


end
