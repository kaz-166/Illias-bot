module MethodSelecter
    extend ActiveSupport::Concern

    # @params[Hash]
    def self.exec(params)
        if    params['id'] == '1'
            GreetingMethods.exec_command_greeting
        elsif params['id'] == '2'
            ManualMethods.exec_commamd_manual
        elsif params['id'] == '3'
            # [todo] paramsで渡すだけにする
            WeatherMethods.exec_command_weather(params['location'], params['hour'])
        elsif params['id'] == '4'
            # 仮実装
            ReminderMethods.exec_commamd_reminder(params['message'])
        else
        end
    end

end