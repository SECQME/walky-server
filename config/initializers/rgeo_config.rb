RGeo::ActiveRecord::SpatialFactoryStore.instance.tap do |config|
  # By default, use the GEOS implementation for spatial columns.
  config.default = RGeo::Geos.factory_generator(srid: 4326)

  config.register(RGeo::Geographic.spherical_factory(srid: 4326), geo_type: "point", sql_type: "geography")
  config.register(RGeo::Geographic.spherical_factory(srid: 4326), geo_type: "polygon", sql_type: "geography")

  # config.default = RGeo::Geographic.spherical_factory(srid: 4326)
  # config.register(RGeo::Geographic.spherical_factory(srid: 4326), geo_type: "point")
end

RGeo::ActiveRecord::GeometryMixin.set_json_generator(:geojson)
