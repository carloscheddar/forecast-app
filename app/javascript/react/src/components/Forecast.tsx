import React, { useEffect, useState } from 'react'
import queryString from 'qs'
import './styles.css'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faSun, faCloudRain, faCloud, faSnowflake, faLocationArrow, faMagnifyingGlass } from '@fortawesome/free-solid-svg-icons'
import { debounce } from 'lodash'

// Object that maps weather types to icons
const WEATHER_ICONS = {
  'clear': faSun,
  'rain': faCloudRain,
  'clouds': faCloud,
  'snow': faSnowflake,
}

// Handles each future section for the forecast
const FutureSection = ({ weatherCondition }) => {
  if (!weatherCondition) return null

  return (
    <div className="container">
      <h3 className="day">{new Date(weatherCondition.date).toLocaleDateString('en', { weekday: 'long' })}</h3>
      <div className="weatherIcon">
        <FontAwesomeIcon icon={WEATHER_ICONS[weatherCondition.weather.toLowerCase()]} size="6x" />
      </div>
      <p className="conditions">{weatherCondition.description}</p>
      <p className="tempRange">
        <span className="high">{parseInt(weatherCondition.temperature_low)}</span>
        |&nbsp;
        <span className="low">{parseInt(weatherCondition.temperature_high)}</span>
      </p>
    </div>
  )
}

const Forecast = () => {
  const [forecast, setForecast] = useState({})
  const [location, setLocation] = useState('')

  // Return only 1 weather condition per day
  const condensedForecast = forecast?.weather_conditions?.reduce((acc, condition) => {
    const day = new Date(condition.date).toDateString()
    acc[day] = condition

    return acc
  }, {})

  // Fetch forecast data from the rails API
  useEffect(() => {
    const fetchData = async () => {
      const params = queryString.stringify({
        forecast: {
          location: location || 'New York'
        }
      })
      const url = `/forecast?${params}`
      const response = await fetch(url)
      const json = await response.json()

      // Only set the forecast if the API responds successfully
      if (response.status === 200) setForecast(json.forecast)
    }
    fetchData()
  }, [location])

  const updateInput = (event: React.ChangeEvent<HTMLInputElement>) => {
    setLocation(event.target.value)
  }

  const main = forecast?.weather_conditions?.[0]
  if (!main) return null

  return (
    <div>
      <div id="current" className="wrapper">
        {/* <nav>
          <button id="locateBtn">
            <FontAwesomeIcon icon={faLocationArrow} />
          </button>
          <button id="unitBtn" data-units="f">f</button>
        </nav> */}
        <div id="search">
          <input id="search" type="text" name="location" onChange={debounce(updateInput, 250)} />
          <FontAwesomeIcon icon={faMagnifyingGlass} />
        </div>

        <h1 className="location">{forecast?.city?.name}, {forecast?.city?.country}</h1>
        <h2 className="date">{new Date(main?.date).toLocaleDateString('en', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}</h2>
        <div className="weatherIcon">
          <FontAwesomeIcon icon={WEATHER_ICONS[main?.weather.toLowerCase()]} size="6x" />
        </div>
        <p className="temp">{parseInt(main?.temperature)}</p>
        <p className="tempRange">
          <span className="high">{parseInt(main?.temperature_low)}</span>
          |&nbsp;
          <span className="low">{parseInt(main?.temperature_high)}</span>
        </p>
        <p className="conditions">{main?.description}</p>
      </div>

      <div id="future" className="wrapper">
        {/* Remove the first element since it's already displayed in the main section */}
        {Object.values(condensedForecast).slice(1, 6).map((condition) => (
          <FutureSection weatherCondition={condition} key={condition?.date}/>
        ))}
      </div>
    </div>
  )
}

export default Forecast
