module Perms
  class Factory

    def self.build(model, controller, options)

      if model.is_a? Symbol
        model_klass = model.to_s
      else
        model_klass = model.class.name
      end

      "Perms::#{model_klass}Rules".constantize.new(model, controller, options)

    end

  end
end