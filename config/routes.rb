Rails.application.routes.draw do
  post '/callback' => 'linebot#callback'
  post '/odyssea'  => 'odyssea#callback'
  get  '/manual'   => 'manual#show'
  get  '/'         => 'manual#show'
end
