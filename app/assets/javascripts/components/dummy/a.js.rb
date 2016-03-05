module Components
  module Dummy
    class A < RW
      expose

      include Plugins::Formable

      def get_initial_state
        {
          form_model: User.new(foo: 'bar')
        }
      end

      def render
        options = ['foo', 'bar', 'baz']
        options.map! do |opt|
          SelectOption.new(value: opt)
        end

        p "render"
        p state.form_model.pure_attributes

        t(:div, {},

          input(Forms::Selects::SinglePlain, state.form_model, :foo, {options: options}),

          t(:button, {onClick: ->{collect}}, 'collect')

        )
      end

      def collect
        collect_inputs
        p state.form_model.pure_attributes        
      end

    end
  end
end