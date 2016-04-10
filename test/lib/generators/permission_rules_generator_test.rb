require 'test_helper'
require 'generators/permission_rules/permission_rules_generator'

class PermissionRulesGeneratorTest < Rails::Generators::TestCase
  tests PermissionRulesGenerator
  destination Rails.root.join('tmp/generators')
  setup :prepare_destination

  # test "generator runs without errors" do
  #   assert_nothing_raised do
  #     run_generator ["arguments"]
  #   end
  # end
end
