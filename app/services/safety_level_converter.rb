class SafetyLevelConverter
  class << self
    SAFETY_LEVELS = [{
      key: "MODERATELY_SAFE",
      int: 1,
      cost: 1,
      cost_min: 1,
      cost_max: 2
    }, {
      key: "MODERATE",
      int: 0,
      cost: 4,
      cost_min: 2,
      cost_max: 8
    }, {
      key: "LOW_SAFETY",
      int: -1,
      cost: 16,
      cost_min: 8,
      cost_max: 32
    }, {
      key: "AVOID",
      int: -2,
      cost: 64,
      cost_min: 32,
      cost_max: 128
    }, {
      key: "UNKNOWN",
      int: -3,
      cost: 256,
      cost_min: 128,
      cost_max: 512
    }]

    def from_key(key)
      SAFETY_LEVELS.find(SAFETY_LEVELS.last) { |d| d[:key] == key }
    end

    def from_int(val)
      SAFETY_LEVELS.find(SAFETY_LEVELS.last) { |d| d[:int] == val }
    end

    def from_cost(val)
      SAFETY_LEVELS.find(SAFETY_LEVELS.last) { |d| d[:cost_min] <= val and d[:cost_max] > val }
    end

    def unknown
      SAFETY_LEVELS.last
    end
  end
end
