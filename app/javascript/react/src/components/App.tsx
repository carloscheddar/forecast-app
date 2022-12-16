import React from 'react'
import { createRoot } from 'react-dom/client'
import Forecast from './Forecast'

const App = () => {
  return (<Forecast />)
}

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById('root')
  const root = createRoot(container)
  root.render(<App />)
})

export default App
