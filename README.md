# Forecast Viewer
This application will render a 5 day weather forecast by fetching the data from the OpenWeatherMap API. It supports fetching the current user location, location search and different temperature unit display.

The rendered application will show icons for various weather conditions, highs and lows as well as a brief description of the weather. The design is fully responsive and condensed on mobile browsers.

### WeatherAPI
This module handles the fetching and normalization of the OpenWeatherMap API. It supports fetching by city as well as zip codes. The module returns a Forecast object which consists of temperature_unit, city, and weather_conditions.

- temperature_unit: The type of temperature unit being requested. Default: Kelvin, Metric: Celsius, Imperial: Fahrenheit.
- city: The information of the city being requested.
- weather_conditions: An array of weather conditions through the week for the requested location.

For more detailed info go to (./lib/weather_api.rb).

### Configuration
The app consists of a Rails backend and a React frontend. Rails will only render the React application at root, every other render will be delegated to React. The React app will query the Rails backend for the weather forecast information.

- Install redis
  https://redis.io/docs/getting-started/
- Install ruby on rails
  https://guides.rubyonrails.org/getting_started.html#creating-a-new-rails-project-installing-rails
- Install gems
  `bundle install`
- Install frontend packages
  `yarn install`
- Run dev server
  Note: Running `rails s` will not compile the React application
  `./bin/dev`
  
### Testing
Test are created with Rspec. The weater_api as well as the forecast controller are fully tested using real-time request tests. Redis is required on the test environment for the cache tests to pass.
`bundle exec rspec`
