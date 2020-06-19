module MethodSelecter
    extend ActiveSupport::Concern

    # @params[Hash]
    def self.exec(params)
        results = {'status' => 'SUCCESS', 'message' => ''}
        if    params['id'] == '1'
            results['status'],  results['message'] = GreetingMethods.exec_command_greeting
        elsif params['id'] == '2'
            results['status'],  results['message'] = ManualMethods.exec_commamd_manual
        elsif params['id'] == '3'
            results['status'],  results['message'] = WeatherMethods.exec_command_weather(params)
        elsif params['id'] == '4'
            # 仮実装
            results['status'],  results['message'] = ReminderMethods.exec_commamd_reminder(params['message'])
        else
            results['message'] = nil
        end
        results
    end

end