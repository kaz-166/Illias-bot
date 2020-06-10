namespase :alert do
    desc '天気の崩れを通知する'
    task :bad_weather -> :enviroment do
        LinebotController.alert
    end
end