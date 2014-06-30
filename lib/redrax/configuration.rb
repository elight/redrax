module Redrax
  class Configuration
    def call(params = {}, &block)
      if params.size > 0 && block
        raise ArgumentError
      end

      if block
        instance_eval(&block)
      else
        add_params_from(params)
      end
    end

    def user(u = nil)
      if u == nil
        @user
      else
        @user = u
      end
    end

    def api_key(a = nil)
      if a == nil
        @api_key
      else
        @api_key = a
      end
    end

    private

    def add_params_from(params = {})
      params.each do |param_name, value|
        send(param_name, value)
      end
    end
  end
end
