class ForecastController < ApplicationController
  def index
    # TODO Add redis caching for 30min using params as key
    begin
      @forecast = WeatherAPI.fetch_forecast(
        forecast_params.fetch(:location, nil),
        is_zip?,
        forecast_params.fetch(:unit, 'imperial'))

      return render json: { forecast: @forecast }
    rescue => e
      return render json: { message: "There was an error fetching the forecast." }, status: :unprocessable_entity
    end
  end

  private

  def forecast_params
    params.require(:forecast).permit(:location, :unit);
  end

  # If there's only numbers in the location assume it's a zip code
  def is_zip?
    forecast_params.fetch(:location, nil).scan(/\D/).empty?
  end
end
