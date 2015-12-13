module Perms
  class Base

    #well this sort of Pundit, but a bit different.
    #controller has #auth!, it raises Perms::Exception if arg is false
    #Perms::Factory.build will prepare Perms::#{passed model class name},
    #it implements checking methods, if no method passed will call method same as current controller action
    #also controller#perms method will call Perms::Factory.build 
    #the idea is 
    # perm = perms(@user)
    #auth! perm (it checkes and prepares attributes and stuff)
    #@user.update(perms.permitted_attributes)
    #FUCK IM SLEEPY AND SEE ME WRITING SHIT!
    #TODO: rewrite docs

    attr_accessor :permitted_attributes, :arbitrary, :model

    def initialize(model, controller, options)
      @options = options
      @current_user = controller.current_user
      @controller = controller
      @model = model
      @arbitrary = {}
      @permitted_attributes = false
    end

    def params
      @controller.params
    end

  end
end