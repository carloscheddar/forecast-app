class ForecastController < ApplicationController
  def index
    begin
      $redis = Redis.new

      # Return the cached result if it exists
      if $redis.exists?(params_key)
        cached = JSON.parse($redis.get(params_key))
        return render json: { forecast: cached, cached: true }
      end

      @forecast = WeatherAPI.fetch_forecast(
        forecast_params.fetch(:location, nil),
        is_zip?,
        forecast_params.fetch(:unit, 'imperial'))

      # Store the fetched forecast for 30 min
      $redis.set(params_key, @forecast.to_json, ex: 1800)

      return render json: { forecast: @forecast, cached: false }
    rescue => e
      return render json: { message: "There was an error fetching the forecast." }, status: :unprocessable_entity
    end
  end

  private

  def forecast_params
    params.require(:forecast).permit(:location, :unit);
  end

  # Creates a unique key based on the params on the request
  def params_key
    forecast_params.to_json
  end

  # If there's only numbers in the location assume it's a zip code
  def is_zip?
    forecast_params.fetch(:location, nil).scan(/\D/).empty?
  end
end
