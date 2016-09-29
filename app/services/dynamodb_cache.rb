class DynamodbCache

  def initialize client, table_name
    @client = client
    @table_name = table_name
  end

	def get_value key
		@client.get_item(
      :table_name => @table_name,
		  :key => {
        :Key => "#{key}"
      },
		  :return_consumed_capacity => "TOTAL")[:item]
	end

  def batch_get_values keys
    resp = @client.batch_get_item(
      request_items: {
        @table_name => {
          keys: keys.map { |k| {:Key => k} }
        }
      },
      return_consumed_capacity: "TOTAL")
    resp.responses[@table_name]
  end

	def set_value key, value
		@client.put_item(
      :table_name => @table_name,
			:item => {
        :Key => "#{key}",
			  "#{key}" => value
      },
			:return_consumed_capacity => "TOTAL")
	end

	def delete_value key
		@client.delete_item(
      :table_name => @table_name,
			:key => {
        :Key => "#{key}"
      },
			:return_consumed_capacity => "TOTAL")
	end

	def update_value key, value, update_key
		@client.update_item(
      :table_name => @table_name,
			:key => {
        :Key => "#{key}"
      },
			:update_expression => "SET #attr_name = :attr_value",
			:expression_attribute_names => {"#attr_name" => update_key},
			:expression_attribute_values => {":attr_value" => value},
 			:return_consumed_capacity => "TOTAL",
			:return_values => "ALL_NEW")
	end

end
