class ApplicationController < ActionController::API
    before_action :ensure_json_request

    private

    def ensure_json_request
        return if request.format == :json
        render status: :not_acceptable, json: { error: "Only JSON requests are allowed" }
    end
end
