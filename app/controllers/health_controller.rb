class HealthController < ApplicationController
  # Skip authentication if you have auth logic

  def index
    render json: { status: "ok", time: Time.current }
  end
end