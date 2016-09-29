class RedisCache

  def initialize host, port, db = 0
    @connection_pool = ConnectionPool.new(size: 5, timeout: 5) { Redis.new(host: host, port: port, db: 0) }
  end

	def get_value key
    json = @connection_pool.with do |conn|
      conn.get(key)
    end
    { key => JSON.parse(json) } if json
	end

  def batch_get_values keys
    json = @connection_pool.with do |conn|
      conn.mget(keys)
    end

    if json
      json = json.select { |o| o }
      i = -1
      json.map do |o|
        i += 1
        { keys[i] => JSON.parse(o) }
      end
    end
  end
end
