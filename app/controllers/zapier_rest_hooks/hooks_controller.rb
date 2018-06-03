require_dependency 'zapier_rest_hooks/application_controller'

module ZapierRestHooks
  class HooksController < ApplicationController
    skip_before_action :verify_authenticity_token
    
    def create
      puts "FFF"
      hook = Hook.new(hook_params)
      puts "PPP"
      res = hook.save
      puts "RES #{res.inspect}"
      puts "errors #{hook.errors.inspect}"
      render nothing: true, status: 500 && return unless res
      puts "KKK"
      Rails.logger.info "Created REST hook: #{hook.inspect}"
      # The Zapier documentation says to return 201 - Created.
      puts "RRRR"
      render json: hook.to_json(only: :id), status: 201
    end

    def destroy
      hook = Hook.find(params[:id]) if params[:id]
      if hook.nil? && params[:subscription_url]
        hook = Hook.find_by_subscription_url(params[:subscription_url]).destroy
      end
      Rails.logger.info "Destroying REST hook: #{hook.inspect}"
      hook.destroy
      head :ok
    end

    private

    def hook_params
      params[:event_name] ||= params[:event]
      params[:hook] = params
      params.require(:hook).permit(:event_name, :target_url, :owner_id, :owner_class_name, :subscription_url)
    end
  end
end
