require 'test_helper'
require 'generators/composer_for/composer_for_generator'

class ComposerForGeneratorTest < Rails::Generators::TestCase
  tests ComposerForGenerator
  destination Rails.root.join('tmp/generators')
  setup :prepare_destination

  # test "generator runs without errors" do
  #   assert_nothing_raised do
  #     run_generator ["arguments"]
  #   end
  # end
end
