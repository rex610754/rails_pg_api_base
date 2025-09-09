class HelloJob
  include Sidekiq::Job

  def perform(name = "world")
    Rails.logger.info "👋 Hello, #{name}! From Sidekiq job."
  end
end