require 'weather_api'

describe "WeatherAPI" do
  let(:response) { JSON.parse(File.read("spec/fixtures/full_forecast_response.json"), object_class: OpenStruct) }

  describe '.fetch_forecast' do
    context 'when called without arguments' do
      it 'responds with an error' do
        expect { WeatherAPI.fetch_forecast() }.to raise_error(ArgumentError)
      end
    end

    context 'when called with a location' do
      context 'when the location is nil' do
        it 'responds with an error' do
          expect { WeatherAPI.fetch_forecast(nil) }.to raise_error('A location must be provided.')
        end
      end

      context 'when the location is not valid' do
        it 'responds with an error' do
          expect { WeatherAPI.fetch_forecast("Middle of Nowhere") }.to raise_error('city not found')
        end
      end

      context 'when the location is valid' do
        it 'responds with weather for that location' do
          forecast = WeatherAPI.fetch_forecast("New York")

          expect(forecast.class).to eq(WeatherAPI::Forecast)
          expect(forecast.city.name).to eq("New York")
          expect(forecast.weather_conditions.length).to eq(40)
          expect(forecast.temperature_unit).to eq 'imperial'
        end
      end

      context 'when the location is a zip code' do
        it 'responds with the weather for the zip code' do
          forecast = WeatherAPI.fetch_forecast("90210", true)

          expect(forecast.class).to eq(WeatherAPI::Forecast)
          expect(forecast.city.name).to eq("Beverly Hills")
          expect(forecast.weather_conditions.length).to eq(40)
          expect(forecast.temperature_unit).to eq 'imperial'
        end
      end

      context 'when the unit is not default ' do
        it 'responds with forcast data in the specified unit' do
          forecast = WeatherAPI.fetch_forecast("90210", true, 'metric')

          expect(forecast.class).to eq(WeatherAPI::Forecast)
          expect(forecast.city.name).to eq("Beverly Hills")
          expect(forecast.temperature_unit).to eq 'metric'
        end
      end
    end
  end

  describe '::WeatherConditions' do
    it 'returns a WeatherConditions object with the normalized data' do
      weather_object = response.list[0]

      normalized = WeatherAPI::WeatherConditions.new(weather_object)
      expect(normalized.weather).to eq "Clear"
      expect(normalized.description).to eq "clear sky"
      expect(normalized.time).to eq 1671084000
      expect(normalized.date).to eq "2022-12-15 06:00:00"
      expect(normalized.temperature).to eq 21.32
      expect(normalized.feels_like).to eq 21.28
      expect(normalized.temperature_low).to eq 21.32
      expect(normalized.temperature_high).to eq 24.16
      expect(normalized.humidity).to eq 68
    end
  end

  describe '::City' do
    it 'returns a City object with normalized data' do
      normalized = WeatherAPI::City.new(response.city)
      expect(normalized.lon).to eq(55.3047)
      expect(normalized.lat).to eq(25.2582)
      expect(normalized.name).to eq('Dubai')
      expect(normalized.country).to eq('AE')
    end
  end

  describe '::Forecast' do
    it 'return a Forecast object with normalized data' do
      forecast = WeatherAPI::Forecast.new(response)
      expect(forecast.temperature_unit).to eq('imperial')
      expect(forecast.city.class).to eq(WeatherAPI::City)
      expect(forecast.weather_conditions.class).to eq(Array)
      expect(forecast.weather_conditions.length).to eq(40)
      expect(forecast.weather_conditions[0].class).to eq(WeatherAPI::WeatherConditions)
    end
  end
end
