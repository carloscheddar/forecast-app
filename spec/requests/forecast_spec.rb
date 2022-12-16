require 'rails_helper'

RSpec.describe 'Forecasts', type: :request do
  describe 'GET /index' do
    let (:forecast) { JSON.parse(response.body, object_class: OpenStruct).forecast }

    context 'when the location is not valid' do
      it 'responds with 422' do
        get '/forecast', params: { forecast: { location: 'Not real place' }}

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when called with a city name' do
      it 'responds with forecast data for the city' do
        get '/forecast', params: { forecast: { location: 'New York' }}

        expect(response).to have_http_status(:success)
        expect(forecast.city.name).to eq("New York")
        expect(forecast.weather_conditions.length).to eq(40)
        expect(forecast.temperature_unit).to eq('imperial')
      end
    end

    context 'when called with a zip code' do
      it 'responds with forecast data for the zip' do
        get '/forecast', params: { forecast: { location: '90210' }}

        expect(response).to have_http_status(:success)
        expect(forecast.city.name).to eq("Beverly Hills")
        expect(forecast.weather_conditions.length).to eq(40)
        expect(forecast.temperature_unit).to eq('imperial')
      end
    end

    context 'when called with metric units' do
      it 'responds with forecast data for the zip' do
        get '/forecast', params: { forecast: { location: '90210', unit: 'metric' }}

        expect(response).to have_http_status(:success)
        expect(forecast.city.name).to eq("Beverly Hills")
        expect(forecast.weather_conditions.length).to eq(40)
        expect(forecast.temperature_unit).to eq('metric')
      end
    end

    context 'when the response is cached' do
      before(:each) do
        # Ensure that the key is not in Redis when we start testing
        $redis = Redis.new
        $redis.del({"location":"90210","unit":"metric"}.to_json)
      end

      it 'only calls the WeatherAPI once' do
        allow(WeatherAPI).to(receive(:fetch_forecast)).and_call_original

        get '/forecast', params: { forecast: { location: '90210', unit: 'metric' }}
        get '/forecast', params: { forecast: { location: '90210', unit: 'metric' }}

        expect(WeatherAPI).to have_received(:fetch_forecast).once

        expect(response).to have_http_status(:success)
        expect(forecast.city.name).to eq("Beverly Hills")
        expect(forecast.weather_conditions.length).to eq(40)
        expect(forecast.temperature_unit).to eq('metric')
      end
    end
  end
end
