class UsersController < BaseController 

  def handle_signup_submit
    c.collect_inputs
    unless c.state.form_model.has_errors?
      c.state.form_model.sign_up({yield_response: true}, payload: {user: c.state.form_model.attributes}).then do |response|
        if e = response.json[:user][:errors]
          c.state.form_model.errors = e
          c.set_state form_model: c.state.form_model 
        else
          c.set_state submitted: true
        end
      end.fail do |response|
        `console.log(#{response})`
      end
    else
      c.set_state form_model: c.state.form_model
    end
  end

  def login
    c.collect_inputs(validate_only: [nil])
    unless c.state.form_model.has_errors?
      CurrentUser.login({}, payload: {session: c.state.form_model.attributes}).then do |response|
        if x = response[:errors]
          c.set_state message: x
        else
          Components::App::Router.history.replaceState(nil, "/users/#{CurrentUser.user_instance.id}")
        end
      end
    else
      c.set_state form_model: c.state.form_model
    end
  end

  def send_password_reset_email
    c.collect_inputs
    unless c.state.form_model.has_errors?
      CurrentUser.request_password_reset({}, payload: {password_reset: c.state.form_model.attributes}).then do |response|
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
      CurrentUser.update_new_password({id: c.state.id}, payload: {user: c.state.form_model.attributes, email: c.state.email}).then do |response|
        Components::App::Router.history.replaceState(nil, "/users/#{CurrentUser.user_instance.id}")
      end.fail do |response|
        c.set_state message: "error"
      end
    else
      c.set_state form_model: c.state.form_model 
    end
  end

end
