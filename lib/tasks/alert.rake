namespace :alert do
    desc '天気の崩れを通知する'
    task :bad_weather => :environment do
			WeatherMethods.alert
    end
end
