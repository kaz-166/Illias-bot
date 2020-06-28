Rails.application.routes.draw do
  post '/callback' => 'linebot#callback'
  get  '/'         => 'manual#show'

  get 'greetings' => 'odyssea#greetings'
  get 'manual'    => 'odyssea#manual'
  get 'weather'   => 'odyssea#weather'
end
