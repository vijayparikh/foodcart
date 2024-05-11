require 'rubygems'
require 'optparse'
require 'ostruct'
require 'rest-client'
require 'awesome_print'
require 'mongoid'
require './lib/mobile_food_facility'
require './lib/food_finder'
require 'table_print'

# setup the default environment mongoid and load it
unless ENV.has_value?('MONGOID_ENV')
  ENV['MONGOID_ENV'] = 'development'
  '>> defaulting to development environment'
end
Mongoid.load! './config/mongoid.yml'

# populate the data into our mongo databse - we should really split this out but the data is small enough for now
MobileFoodFacility::load_data_set

finder = FoodFinder.new
options = OpenStruct.new
OptionParser.new do |opt|
  opt.on('-f', '--food <food>', 'the food that cart offers') {|o| finder.food = o}
  opt.on('-t', '--type <type>', 'type of cart') {|o| finder.type = o}
  opt.on('-a', '--address <address>', 'address where you are located') {|o| finder.address = o}
  opt.on('-d', '--distance <distance>', 'distance between carts') {|o| finder.distance = o.to_i}
  opt.on('-v', '--vendor <vendor>', 'food cart owner') {|o| finder.vendor = o}

  opt.on('-h', '--help', 'Prints this help') do
    puts opt
    exit
  end
end.parse!

# find those carts!
x = finder.execute

# print out the info in a tabular format
tp finder.formated_records






