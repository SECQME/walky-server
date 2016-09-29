collection :@report_categories

attributes :id, :name, :created_at, :updated_at

node(:categories) { |group|
	group.report_categories.map { |category| {
			:id => category.id,
			:name => category.name,
			:created_at => category.created_at,
			:updated_at => category.updated_at
		}
	}
}
