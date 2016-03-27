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

        t(Components::Shared::ThinProgressBar, {interval: 500})
      end

      def collect
        collect_inputs
        p state.form_model.pure_attributes        
      end

    end
  end
end
