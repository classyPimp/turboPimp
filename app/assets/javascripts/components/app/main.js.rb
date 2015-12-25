module Components
  module App
    class Main < RW
      
      expose

      class << self
        attr_accessor :instance
        attr_accessor :props_from_server
        attr_accessor :history
      end

      def init
        self.class.instance = self
      end

      def get_initial_state  
        if x = self.class.props_from_server.current_user
          p Hash.new(x.to_n)
          CurrentUser.user_instance = Model.parse(Hash.new(x.to_n))
          CurrentUser.logged_in = true
        end
        {}
      end

      def assign_controller
        @controller = AppController.new(self)
      end
      
      def render
        t(:div, {},
          t(Components::Menues::Index, {ref: "menu"}),
          t(Shared::Flash::Holder, {ref: "flash"}),
          spinner,
          t(:div, {},
            children
          ),
          modal({},
            t(:p, {}, "WHAT UP DOWGS")
          )
        )
      end

      #flash message example
      #msg = Shared::Flash::Message.new( t(:button, {onClick: ->{self.x}}, "PRREASS ME"), "success")
      #Components::App::Main.instance.ref(:flash).rb.add_message(msg)
      #
      #modal example
      #def modal_handler 
      #  ref(:modal).__opalInstance.open(t(:p, {}, "THE HEADER"))
      #end
    end
    
  end
end


Document.ready? do 
require "benchmark"
  @array = [
    {id: 1, parent_id: 0},
    {id: 2, parent_id: 1},
    {id: 3, parent_id: 0},
    {id: 4, parent_id: 2},
    {id: 5, parent_id: 3},
    {id: 6, parent_id: 1},
    {id: 7, parent_id: 6},
    {id: 8, parent_id: 2}
  ]
  target_array = []

  def build_hierarchy target_array, n
      @array.select { |h| h[:parent_id] == n }.each do |h|
        target_array << {id: h[:id], children: build_hierarchy([], h[:id])}
      end
      target_array
  end


  time = Benchmark.measure do
    100000.times do
      target_hash = Hash.new { |h,k| h[k] = { id: nil, children: [ ] } }

      @array.each do |n|
          id, parent_id = n.values_at(:id, :parent_id)
          target_hash[id][:id] = n[:id]
          target_hash[parent_id][:children].push(target_hash[id])  
      end
      target_hash = nil
    end
    
  end
  
    puts time
  
end