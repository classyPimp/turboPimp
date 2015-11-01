class UsersController < BaseController

  EMAIL_REGEX = /^[-a-z0-9~!$%^&*_=+}{\'?]+(\.[-a-z0-9~!$%^&*_=+}{\'?]+)*@([a-z0-9_][-a-z0-9_]*(\.[-a-z0-9_]+)*\.(aero|arpa|biz|com|coop|edu|gov|info|int|mil|museum|name|net|org|pro|travel|mobi|[a-z][a-z])|([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}))(:[0-9]{1,5})?$/i

  def submit_form
    ->(e){
      e = Native(e)
      e.prevent
      errors = nil
      c.state.inputs[:email] = c.ref(:email_input).value
      c.state.inputs[:password] = c.ref(:password_input).value
      c.state.inputs[:password_confirmation] = c.ref(:password_confirmation_input).value
      errors = validate(c.state.inputs)
      if errors == c.blank_errors
        c.state.errors = c.blank_errors
        c.state.user.sign_up({yield_response: true}, user: c.state_to_h(:inputs)).then do |response|
          if e = response[:user][:errors]
          	c.set_state errors: e 
          else
        		c.set_state submitted: true
          end
        end.fail do |response|
          `console.log(#{response})`
        end
      else
        c.set_state errors: errors
      end
    }
  end

  def validate(attrs)
    errors = c.blank_errors
    unless attrs[:email].match(self.class::EMAIL_REGEX)
      errors[:email] << "you should provide valid email"
    end
    if attrs[:password] != attrs[:password_confirmation] && attrs[:password] != nil
      errors[:password_confirmation] << "confirmation does not match"
    end
    if attrs[:password].length < 8
      errors[:password] <<  "can't be less than 8 letters"
    end
    errors
  end


  def login
    p "#{self}.login"
    email = c.ref(:email_input).value
    password = c.ref(:password_input).value
    if email != "" || password != ""
      CurrentUser.login({}, session: {email: email, password: password}).then do |variable|
        App.history.replaceState(nil, "/users/#{CurrentUser.user_instance.id}")
        AppController.user_logged_in
      end
    end 
  end

  def send_password_reset
    email = c.ref(:email_input).value
    if email
      CurrentUser.request_password_reset({}, password_reset: email).then do |response|
        
      end
    end
  end

  def send_password_reset_email
    c.state.message = false
    c.state.errors  = []
    c.state.inputs[:email] = c.ref(:email_input).value
    unless c.state.inputs[:email].match(self.class::EMAIL_REGEX)
      c.state.errors << "you should provide valid email"
    end
    if c.state.errors.empty?
      CurrentUser.request_password_reset({}, password_reset: {email: c.state.inputs.email}).then do |response|
        c.set_state message: "instructions were sent to you"
      end.fail do |response|
        c.set_state errors: response[:errors]
      end
    else
      c.set_state errors: c.state.errors
    end
  end

  def update_new_password
    c.state.message = false
    c.state.errors = c.blank_errors
    errors = {password: [], password_confirmation: []}
    c.state.inputs[:password] = c.ref(:password_input).value
    c.state.inputs[:password_confirmation] = c.ref(:password_confirmation_input).value
    if c.state.inputs[:password] != c.state.inputs[:password_confirmation] && c.state.inputs[:password] != nil
      errors[:password_confirmation] << "confirmation does not match"
    end
    if c.state.inputs[:password].length < 8
      errors[:password] <<  "can't be less than 8 letters"
    end
     p errors
     p c.blank_errors
    if errors == c.blank_errors
      CurrentUser.update_new_password({id: c.state.id}, {user: {password: c.state.inputs[:password], 
                                          password_confirmation: c.state.inputs[:password_confirmation]}, email: c.state.email,
                                          })
      .then do |response|
        App.history.replaceState(nil, "/users/#{CurrentUser.user_instance.id}")
        AppController.user_logged_in
      end.fail do |response|
        c.set_state message: "error"
      end
    else
      c.set_state errors: errors 
    end
  end

end
