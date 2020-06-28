Rails.application.routes.draw do
  post '/callback' => 'linebot#callback'
  post '/odyssea'  => 'odyssea#callback'
  get  '/manual'   => 'manual#show'
  get  '/'         => 'manual#show'

  get 'greetings' => 'odyssea#greetings'
  get 'weather'   => 'odyssea#weather'
end
