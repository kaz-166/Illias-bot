namespace :alert do
    desc 'Alert a bad weather'
    task :bad_weather => :environment do
		WeatherMethods.alert
    end

    desc "Remind user's event"
    task :reminder => :enviroment do
        ReminderMethods.remind
    end
end
