class FoodFinder
  attr_accessor :food, :vendor, :type, :address, :distance, :max_return, :found_records, :formated_records, :current_geo

  def initialize
    setup_mongo_client
    setup_radar_client
    @distance = 500   # set default distance from address to 500 meters
    @max_return = 25  # set default return to 25 food trucks
    @found_records = []
    @formated_records = []
  end

  # Setup the mongo db access - load the config from the /config/mongoid.yml file and create a mongo client object
  def setup_mongo_client
    environment = ENV.has_value?('MONGOID_ENV') ? ENV['MONGOID_ENV'] : 'development'
    y = YAML.load(File.read('./config/mongoid.yml'))
    database = y[environment]['clients']['default']['database']
    host = y[environment]['clients']['default']['hosts'].first
    @client = Mongo::Client.new([ host ], :database => database)
  end

  # load the appropriate API key
  def setup_radar_client
    environment = ENV.has_value?('RADAR_ENV') ? ENV['RADAR_ENV'] : 'development'
    y = YAML.load(File.read('./config/radar.yml'))
    @radar_api_key = y[environment]['api_key']
  end

  # Given the address, we do a lookup with Radar service
  def gps_of_address
    uri = "https://api.radar.io/v1/search/autocomplete?query= #{CGI.escape(@address)}"
    resp = RestClient.get(uri.encode, headers = { Authorization: @radar_api_key })

    # we get the GeoJSON point matching that address.  We only care about the co-ordinates
    @current_geo = JSON.parse(resp)['addresses'][0]['geometry']
  end

  # the selector for vendor
  def owner_query
    { 'applicant' => { '$regex' => @vendor, '$options' => 'i'} }
  end

  # the selector for type of cart
  def type_query
    { 'facility_type' => { '$regex' => @type, '$options' => 'i' } }
  end

  # the selector for the food
  def food_query
    { 'food_items' => { '$regex' => @food, '$options' => 'i' } }
  end

  # This is the query that will use the geo co-ordinates we queried from Radar an apply the distance parameter as a bound
  def address_query
    gps_of_address # get the geo co-ordinates of the address
    gps_query = { 'location_gps' =>
      { '$near' =>  # we are filter for the nearest one
          { '$geometry' =>  # using the GeoJSON point format
              { 'type' => 'Point',
                'coordinates' => @current_geo['coordinates'] },
            '$maxDistance' => @distance } } } # bounding by the distance
  end

  # We go through all of the found records that were within the distance range/vendor/food and are now going to
  # query for each record to see how far away it is by car & foot.
  def format_result
    @formated_records = []
    origin_longitude = @current_geo['coordinates'][0]  # these are the co-ordinates of where we are
    origin_latitude =  @current_geo['coordinates'][1]

    # iterate through all of the found records
    @found_records.each do |record|
      # the co-ordinates of the food truck
      destination_longitude = record['longitude']
      destination_latitude = record['latitude']

      # api call to query the distance between location & food truck
      uri = "https://api.radar.io/v1/route/distance?origin=#{origin_latitude},#{origin_longitude}&destination=#{destination_latitude},#{destination_longitude}&modes=foot,car&units=imperial"
      resp = RestClient.get(uri.encode, headers = { Authorization: @radar_api_key })
      r = JSON.parse(resp)

      # and capture it
      info = {}
      info['owner'] = record['applicant']
      info['address'] = record['address']
      info['food'] = record['food_items']
      info['car'] = r['routes']['car']['duration']['text']
      info['foot'] = r['routes']['foot']['duration']['text']
      @formated_records << info
    end
  end

  # This is the main section - build the queries, execute, format output
  def execute
    query_composite = []
    @found_records = []
    # bulild the mongo query components
    query_composite << owner_query unless @vendor.nil? # append the query for the vendor if vendor was provided
    query_composite << food_query unless @food.nil? # append the query for food if food was provided
    query_composite << type_query unless @type.nil? # append the query for the type if food was provided
    query_composite << address_query unless @address.nil? # append the query for address if it was provided

    # combine all of the queries with an 'and' conditional
    if query_composite.size > 0
      collection = @client[:mobile_food_facilities]
      result = collection.find(
        { '$and' => query_composite }
      ).limit(@max_return)

      result.each do |row|
        @found_records << row
      end
    end
    # calculate the distance to each food cart
    format_result

    # return it
    return @found_records
  end
end
