set :output, "#{path}/log/cron.log"

every 1.day do
  rake "index:update"
end
