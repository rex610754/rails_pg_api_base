# README

## Development Setup

1. Environment Setup  
   Copy the example environment file and create your local `.env`:
   ```sh
   cp .env.example .env  

3. Common Commands
   ```sh
   docker-compose up --build         # build and run containers  
   docker-compose up                 # run containers  
   docker-compose down               # stop containers  
   docker-compose up -d              # run containers in detached mode  
   docker-compose logs               # check logs  
   docker-compose exec api bash      # access Rails container bash  
   docker-compose exec api bin/rails db:migrate   # run migrations  
   docker-compose exec api bin/rails c            # run Rails console  

---

## Adding / Removing Gems

1. Add gems  
   - Stop containers  
   - Add gems in the Gemfile  
   - Start containers again  
   - You will see the Gemfile.lock updated automatically  

2. Remove gems  
   - Stop containers  
   - Remove gems from the Gemfile  
   - Start containers again  
   - Gemfile.lock should update  
   - Always commit both Gemfile and Gemfile.lock  

---

## Logger Notes

Rails logs for production are sent to STDOUT.  
Configure CloudWatch Logs Agent (or the awslogs driver in Docker Compose) with a retention period (e.g., 7, 14, or 30 days).  

If you want to manage logs manually, add this configuration in `config/environments/production.rb`:  

```ruby
config.logger = Logger.new(
  Rails.root.join("log", "#{Rails.env}.log"),
  10,                  # keep 10 rotated files
  50 * 1024 * 1024     # max size 50 MB per file
)
