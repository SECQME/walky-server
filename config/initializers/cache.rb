if Rails.env.production?
  $redis_cache = RedisCache.new("10.20.11.216", 6379)
else
  $redis_cache = RedisCache.new("127.0.0.1", 6379)
end

$saferstreets_grid = SaferStreetsGrid.new(
  $redis_cache
)
