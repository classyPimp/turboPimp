module Users

  class LoginInfo < RW

    expose_as_native_component

    def initial_state
      {
        logged_in: CurrentUser.logged_in,
        current_user: CurrentUser.user_instance
      }
    end

    def component_will_mount
      AppController.login_info_component = self      
    end

    def component_will_unmount
      AppController.login_info_component = false
    end

    def update_current_user
      p "#{self} update_current_user"
      state.current_user = CurrentUser.user_instance
      set_state logged_in: CurrentUser.logged_in
    end

    def on_user_logout
      state.current_user = CurrentUser.user_instance
      set_state logged_in: CurrentUser.logged_in
    end

    def request_credentials
      CurrentUser.get_current_user({component: self}).then do |response|
        if CurrentUser.logged_in == true
          state.current_user = CurrentUser.user_instance
          set_state(logged_in: CurrentUser.logged_in)
        end
      end.fail do |response|
        
        set_state logged_in: (CurrentUser.logged_in = false)
      end
    end

    def render
      t(:div, {}, 
        if state.logged_in
          link_to("you are logged_in as #{state.current_user.email}", "/users/#{CurrentUser.user_instance.id}")
        else
          t(:div, {}, "you are not logged in",
            t(:br,{}),
            link_to("login", "/users/login"),
            t(:br, {}),
            link_to("signup", "/users/signup"),
            t(:br, {})
          )
        end
      )
    end
  end

end