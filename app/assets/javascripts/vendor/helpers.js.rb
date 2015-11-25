require "./model"

module Helpers
  
  class Cookie
    def self.get()
      c = `document.cookie`
      x = c.include? "l="
    end
  end

  class ::RW
    
    
  #### REACT ROUTER HELPERS
    def link_to(body, link, options = nil)
     if block_given?
      body = yield
     end
      t(`Link`, {to: link, query: options}, body)    
    end
  ###### /REACT ROUTER HELPERS
  #####   SPINNER
    attr_accessor :has_spinner

    require "components/shared/spinner"

    def spinner
      @has_spinner = true
      t(Shared::Spinner, {ref: "spinner"})
    end

    def spinner_instance
      ref(:spinner).__opalInstance
    end
  #####   /SPINNER

  #####     MODAL
    ### INCLUDES BOOTSTRAP MODAL HELPER
    # in render simply call modal({className: "something"}, 
    #  t(:p, {},"foobar")
    #)
    # you can call modal_open(passing head, and content)
    #
    require "components/shared/modal"

    def modal(options = {}, passed_children = `null`)
      options[:ref] = "modal"
      t(Shared::Modal, options, 
        passed_children
      )
    end

    def modal_instance
      ref(:modal).__opalInstance
    end

    def modal_open(head_content = false, content = false)
      modal_instance.open(head_content, content)
    end

    def modal_close(preserve = false)
      modal_instance.close(preserve)
    end
  ######    \MODAL
  end

  class ::RequestHandler

    def defaults_on_response
      authorize!
      (@component.spinner_instance.off if @component.has_spinner) if @component
      if @response.status_code == 404
        App.history.replaceState(nil, "/404")
      elsif @response.status_code == 500
        App.history.replaceState(nil, "/505?status_code=500")
      end
    end

    def defaults_before_request
      (@component.spinner_instance.on if @component.has_spinner) if @component
    end

    def authorize!
      #obvious
      if @response.status_code == 403
        App.history.replaceState(nil, "/forbidden")
      end
    end
  end

end