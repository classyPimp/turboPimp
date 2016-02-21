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
        
        # t(:form, {className: "navbar-form navbar-left"},
        #   t(:ul, {},
        #     t(Components::Users::LoginInfo, {})
        #   )
        # ),


      def render
        t(:span, {className: 'login_info'}, 
          *if state.logged_in
            t(:span, {className: "nav navbar-nav navbar-left"},
              link_to("", "/users/dashboard") do
                t(:button, {className: 'btn btn-default navbar-btn'}, 'my account')
              end,
              link_to("", "/users/signup") do
                t(:button, {className: 'btn btn-default navbar-btn', onClick: ->(){logout_user}, style: {cursor: "pointer"}.to_n}, 'logout')
              end
            )
          else
            t(:span, {className: "nav navbar-nav navbar-left"},
              link_to("", "/users/login") do
                t(:button, {className: 'btn btn-default navbar-btn'}, 'login')
              end,
              link_to("", "/users/signup") do
                t(:button, {className: 'btn btn-default navbar-btn'}, 'signup')
              end
            )
          end
        )
      end

      def logout_user
        AppController.logout_user
      end

    end

  end
end