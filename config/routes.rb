Rails.application.routes.draw do
  post '/callback' => 'linebot#callback'
  get  '/manual'   => 'manual#show'
  get  '/'         => 'manual#show'
end
