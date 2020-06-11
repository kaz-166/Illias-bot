namespace :alert do
    desc 'Alert a bad weather'
    task :bad_weather => :environment do
			WeatherMethods.alert
    end
end
