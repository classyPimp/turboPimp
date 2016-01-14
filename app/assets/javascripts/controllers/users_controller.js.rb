class UsersController < BaseController 

  def handle_signup_submit
    c.collect_inputs
    unless c.state.form_model.has_errors?
      c.state.form_model.sign_up(yield_response: true, payload: {user: c.state.form_model.attributes}).then do |response|
        if e = response.json[:user][:errors]
          c.state.form_model.errors = e
          c.set_state form_model: c.state.form_model 
        else
          alert "signed in"
          CurrentUser.get_current_user
          Components::App::Router.history.pushState({}, "/users/show/#{response.json[:user][:id]}")
        end
      end.fail do |response|
        `console.log(#{response})`
      end
    else
      c.set_state form_model: c.state.form_model
    end
  end

  def login
    c.collect_inputs(validate: false)
    unless c.state.form_model.has_errors?
      CurrentUser.login(payload: {session: c.state.form_model.attributes}).then do |response|
      begin
        if x = response[:errors]
          c.set_state message: x
        else
          if c.props.no_redirect
            alert "logged_in"
          else  
            Components::App::Router.history.pushState(nil, "/users/show/#{CurrentUser.user_instance.id}")
          end
          p "login props"
          `console.log(#{c.props})`
          p "cur_usr"
          `console.log(#{CurrentUser.user_instance})`
          p 'c.props.on_login'
          p c.props.on_login
          if c.props.on_login
            p "gon pass cur user: #{CurrentUser.user_instance}"
            c.emit("on_login", CurrentUser.user_instance)
          end
        end
      rescue Exception => e
        p e
      end
      end
    else
      c.set_state form_model: c.state.form_model
    end

  end

  def send_password_reset_email
    c.collect_inputs
    unless c.state.form_model.has_errors?
      CurrentUser.request_password_reset(payload: {password_reset: c.state.form_model.attributes}).then do |response|
        c.set_state message: "instructions were sent to you"
      end.fail do |response|
        c.state.form_model.errors = response[:errors]
        c.set_state form_model: c.state.form_model
      end
    else
      c.set_state form_model: c.state.form_model
    end
  end

  def update_new_password
    c.collect_inputs(validate_only: [:password, :password_confirmation])
    unless c.state.form_model.has_errors?
      CurrentUser.update_new_password(wilds: {id: c.state.id}, payload: {user: c.state.form_model.attributes, email: c.state.email}).then do |response|
        Components::App::Router.history.pushState(nil, "/users/show/#{CurrentUser.user_instance.id}")
      end.fail do |response|
        c.set_state message: "error"
      end
    else
      c.set_state form_model: c.state.form_model 
    end
  end

end
