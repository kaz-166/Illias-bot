module MethodSelecter
    extend ActiveSupport::Concern

    # @params[Hash]
    def self.exec(params)
        results = {'status' => Settings.status.success, 'message' => '', 'expression' => Settings.expression.normal }
        if    params['id'] == '1'
            results['status'],  results['message'], results['expression'] = GreetingMethods.exec_command_greeting
        elsif params['id'] == '2'
            results['status'],  results['message'], results['expression'] = ManualMethods.exec_commamd_manual
        elsif params['id'] == '3'
            results['status'],  results['message'], results['expression'] = WeatherMethods.exec_command_weather(params)
        elsif params['id'] == '4'
            # 仮実装
            results['status'],  results['message'], results['expression'] = ReminderMethods.exec_commamd_reminder(params['message'])
        else
            results['status'] = Settings.status.invalid_id
            results['message'] = nil
        end
        results
    end

end