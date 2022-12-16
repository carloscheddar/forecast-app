require 'httpparty'
require 'debug'

# API key generously donated by a codepen user
API_KEY = '8fa23948b5ec171a5a4e67936002ce76'
API_HOST = 'https://api.openweathermap.org'

# A module that calls the Open Weather Map API to get weather forecast data
# The data response will be parsed and normalized
module WeatherAPI
  # Given a city name or zip fetch the weather forecast
  # @param location [String] Either a city name or a zip code.
  # @param zip [Boolean] Determines if the location is a zip code.
  # @param unit [String] Determines the type of temperature units to request. Default: Kelvin, Metric: Celsius, Imperial: Fahrenheit.
  # @return [Forecast] A Forecast object with the normalized weather conditions for the location.
  def self.fetch_forecast(location, zip = false, unit = 'imperial')
    raise "A location must be provided." unless location

    params = {
      units: unit,
      appid: API_KEY
    }
    # If the zip boolean is set, use the zip param instead
    zip ? (params[:zip] = location) : (params[:q] = location)

    response = HTTParty.get("#{API_HOST}/data/2.5/forecast", query: params)
    parsed = JSON.parse(response.body, object_class: OpenStruct)

    # Return the error message from the API
    raise parsed["message"] if (response.code > 400)

    Forecast.new(unit, parsed)
  end

  class Forecast
    # @return [String] Unit of temperature. Default: Kelvin, Metric: Celsius, Imperial: Fahrenheit.
    attr_reader :temperature_unit

    # @return [Array<WeatherConditions>] List of all weather conditions for the city.
    attr_reader :weather_conditions

    # @return [City] Information of the city with the forecast data
    attr_reader :city

    # @param tempurature_unit [String] Unit of temperature. Default: Kelvin, Metric: Celsius, Imperial: Fahrenheit.
    # @param response [OpenStruct] OpenWeatherMap API response for a forecast request
    def initialize(temperature_unit = 'imperial', response)
      @temperature_unit = temperature_unit
      @city = City.new(response.city)
      @weather_conditions = get_weather_conditions(response.list)
    end

    private

    # Instantiates a WeatherConditions class for each weather condition of the response
    def get_weather_conditions(list)
      list.map { |condition| WeatherConditions.new(condition)}
    end
  end

  class WeatherConditions
    # @return [String] A brief string description of the weather
    attr_reader :weather

    # @return [String] A longer description of the weather
    attr_reader :description

    # @return [Time] Time of the weather
    attr_reader :time

    # @return [String] Date string of the weather
    attr_reader :date

    # @return [Float] Average temperature for the time
    attr_reader :temperature

    # @return [Float] What the temperature feels like for people
    attr_reader :feels_like

    # @return [Float] Low temperature for the time
    attr_reader :temperature_low

    # @return [Float] High temperature for the time
    attr_reader :temperature_high

    # @return [Float] Humidity for the time
    attr_reader :humidity

    # Create a new WeatherConditions object
    #
    # @param object [OpenStruct] A parsed weather object from OpenWeatherMap
    def initialize(object)
      @weather = object.dig(:weather, 0, :main)
      @description = object.dig(:weather, 0, :description)
      @time = object[:dt]
      @date = object[:dt_txt]
      @temperature = object.dig(:main, :temp)
      @feels_like = object.dig(:main, :feels_like)
      @temperature_low = object.dig(:main, :temp_min)
      @temperature_high = object.dig(:main, :temp_max)
      @humidity = object.dig(:main, :humidity)
    end
  end

  class City
    # @return [Float] Longitude of the location
    attr_reader :lon

    # @return [Float] Latitude of the location
    attr_reader :lat

    # @return [String] Name of the location
    attr_reader :name

    # @return [String] Country of the location
    attr_reader :country

    # Create a new City object
    #
    # @param city_object [OpenStruct] A city object from the OpenWeatherMap API response
    def initialize(city_object)
      @lon = city_object.coord.lon
      @lat = city_object.coord.lat
      @name = city_object.name
      @country = city_object.country
    end
  end
end

