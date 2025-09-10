# Default threads
max_threads_count = ENV.fetch("RAILS_MAX_THREADS", 5).to_i
min_threads_count = ENV.fetch("RAILS_MIN_THREADS", max_threads_count).to_i
threads min_threads_count, max_threads_count

# Default port
port ENV.fetch("PORT", 80)

# Environment
environment ENV.fetch("RAILS_ENV") { "development" }

# PID and state files (important for restarts)
pidfile ENV.fetch("PIDFILE", "tmp/pids/server.pid")
state_path ENV.fetch("STATE_PATH", "tmp/pids/puma.state")

# Allow restart with `bin/rails restart`
plugin :tmp_restart

if ENV["RAILS_ENV"] == "production"
  # Use multiple workers in production (processes)
  workers ENV.fetch("WEB_CONCURRENCY", 2).to_i

  # Preload app for faster workers & lower memory usage
  preload_app!

  on_worker_boot do
    # Reconnect to ActiveRecord on worker boot
    ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
  end
end
