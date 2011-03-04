# EDIT

$LOAD_PATH.unshift(Dir.getwd)
require 'example_app_name'
use Rack::ShowExceptions
run ExampleAppName.new