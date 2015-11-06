module Plugins
  module Formable

    #needs state form_model
    #your base should have state.form_model, the Model instance
    #that will contain the validation rules and attr it has
    #and which needs some inputs
     
    def initialize
      @inputs_counter = -1
      #to understand what it does refer to #input method
      super
    end

    def __component_will_update__
      @inputs_counter = -1
      #to understand what it does refer to #input method
      #here it resets for it not to increment infinitely
      #also this can help in keying inputs probably idk
      super
    end

    def input(elem, model, attr, options = {}, *_children)
      #this method calls the input element that you define for single attr handling
      #model : Model => the model which attrs will take from inputs
      #attr => attribute on model wich will recive value of the input
      #elem => React element which will be used as input handler for attr
      #        this element will be rendered
      @inputs_counter += 1
      #the @inputs_counter servers the purpose of giving uniq ref name to the input elem
      #for further accessing it 
      options[:model] = model
      options[:attr] = attr
      options[:ref] = "_input_#{@inputs_counter}"
      #the given ref will go not to the input dom element but the RW element
      #that has to implement collect method (which gets the concrete input)
      #the ref is needed to get taht RW class object (as ref(_input_1).__opalInstance.collect)
      options[:keyed] = @inputs_counter
      #probably needs reworking on this can't remember why I did this
      t(elem, options, *_children)
      #basically the result
      #children are children, the life purpose of each element)

      #options will 
    end
    
    def collect_inputs(options = {})
      #so you've called inputs in your render
      #input called the input handling RW class
      #that class was given a ref
      #now with this method you collect all the values from all the inputs
      #at once. The input class should implement #collect method for getting the actual 
      #values from user interactions
      Hash.new(refs.to_n).each do |k,v|
        if k.include? "_input"
        #in #input the ref of "_input#{@input_counter}"
        #so any ref starting _input is input that's how you roll now)
          v.__opalInstance.collect
          #as it was mentioned RW class responsible for single attr input handling
          #should implement #collect method which will get the actual value from user interaction
        end
      end
      state.form_model.reset_errors
      #your input handlers may rely on errors for showing them to user
      #so it basically resets all errors
      #TODO: ammend #reset_errors on model if from_model is Asssociation of Model
      options[:validate_only] ||= []
      state.form_model.validate(only: options[:validate_only])
      #Model implements #validate method which does TADA validation!
      state.form_model
      #returns the model with inputs
      #there you do what you want
      #e.g. collect_inputs.has_errors ? form_model.save : set_state form_model: state.form_model 
      #=> to either to pass to server, or to show errors 
    end

  end
end