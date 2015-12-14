module Components
  module Users

    class LoginInfo < RW

      expose

      def get_initial_state
        {
          logged_in: CurrentUser.logged_in,
          current_user: CurrentUser.user_instance
        }
      end

      def component_will_mount
        CurrentUser.sub_to(:on_user_logged_in, self)
        CurrentUser.sub_to(:on_user_logout, self)    
      end

      def component_will_unmount
        CurrentUser.unsub_from(:on_user_logged_in, self)
        CurrentUser.unsub_from(:on_user_logout, self)
      end

      #FROM SUB_TO CURRENT_USER
      def on_user_logged_in(user)
        set_state current_user: user
        set_state logged_in: true
      end
      #FROM SUB_TO CURRENT_USER
      def on_user_logout(user)
        set_state current_user: user
        set_state logged_in: false
      end
      
      def render
        t(:div, {}, 
          if state.logged_in
            link_to("you are logged_in as #{state.current_user.email}", "/users/show/#{CurrentUser.user_instance.id}")
          else
            t(:div, {}, 
              link_to("Login  |", "/users/login"),
              t(:span, {}, link_to(" signup", "/users/signup"))
            )
          end
        )
      end

    end

  end
end