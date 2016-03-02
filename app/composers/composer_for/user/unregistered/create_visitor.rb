 class ComposerFor::User::Unregistered::CreateVisitor

  include Services::PubSubBus::Publisher

  def initialize(controller, roles_to_add = false)
    @controller = controller  
    @roles_to_add = roles_to_add 
  end

  def run
    compose
    clear   
  end

  def compose

    @user = ::User.new
    User.arbitrary[:register_as_guest] = true
    @user.handle_unregistered_user
    @user.registered = false

    if @roles_to_add
      @roles_to_add.map! { |name|
        {name: name}
      }
    end

    @user.roles_attributes = @roles_to_add

    if @user.save
      @controller.log_in(@user)
      @controller.remember(@user)
      publish(:ok, @user)
    end
  end

  def clear
    User.arbitrary.delete(:register_as_guest)
    unsubscribe_all
  end

end