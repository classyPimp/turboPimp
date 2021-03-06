require 'fileutils'

class ComposerForGenerator < Rails::Generators::NamedBase

  source_root File.expand_path('../templates', __FILE__)

  def initialize(args, foo, bar)
    @passed_arg = args[0]

    prepare_file_name
    
    prepare_class_name

    create_file_with_content

  end


private

  def prepare_file_name
    @file_name = "app/composers/composer_for/#{@passed_arg}.rb"
  end

  def prepare_class_name

    splitted = @passed_arg.split('/')

    class_parts = []

    splitted.each do |part|
      
      splitted_parts = part.split('_')

      to_classed_name = ""

      splitted_parts.each do |parts_part|
        to_classed_name += parts_part.capitalize
      end  

      class_parts << to_classed_name

    end

    @class_name = class_parts.join('::')

  end

  def file_contents
    <<-FILE
class ComposerFor::#{@class_name}

  include Services::PubSubBus::Publisher

  def initialize(model, params, controller)
    @model = model
    @params = params
    @controller = controller
  end

  def run
    
    clear
  end

  def clear
    unsubscribe_all
  end

end
    FILE
  end

  def create_file_with_content    

    dirname = File.dirname(Rails.root.join(@file_name))

    unless File.directory?(dirname)
      FileUtils.mkdir_p(dirname)
    end

    File.open(Rails.root.join(@file_name), 'w') {|f| f.write(file_contents) }
  
  end

end
