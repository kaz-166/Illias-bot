namespace :alert do
    desc '天気の崩れを通知する'
    task :bad_weather => :environment do
        LinebotController.alert
    end
end
