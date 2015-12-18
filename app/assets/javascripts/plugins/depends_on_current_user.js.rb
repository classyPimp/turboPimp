module Plugins
  module DependsOnCurrentUser

    def component_will_mount
      state.current_user = User.new
      CurrentUser.get_current_user(extra_params: {roles: self.class.roles_to_fetch}).then do |user|
        if user.is_a? User
          depends_on_current_user_loaded(user) if self.respond_to? :user_loaded
          CurrentUser.user_instance = user
          if user.has_role? self.class.roles_to_fetch 
            set_state current_user: user
          end
        else
          user = nil
        end
      end
      super
    end

    def self.included(base)
      base.extend(ClassMethods)
    end


    module ClassMethods

      def roles_to_fetch
        @roles_to_fetch ||= []
      end
      
      def set_roles_to_fetch(*args)
        @roles_to_fetch = args
      end

    end

  end
end