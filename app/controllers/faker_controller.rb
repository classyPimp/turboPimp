class FakerController < ApplicationController

	def home
    @current_user = current_user.as_json(only: [:id, :email])				
	end

  def console
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
      build_hierarchy [], 0
      target_hash = []
    end
    
  end
  
    raise "#{time}"
  end

	def test
    x = {options: ["foo", "bar", "baz", "cux"]}
		render json: x
	end

  def restricted_asset
    if current_user
      send_file Rails.root + "app/assets/javascripts/foo.js.rb", type: "application/javascript"
    else
      head 403
    end
  end
end
