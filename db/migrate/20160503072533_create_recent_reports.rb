class CreateRecentReports < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE EXTENSION kmeans;
      CREATE EXTENSION btree_gist;

      CREATE MATERIALIZED VIEW #{RecentReport.table_name} AS
        (
          SELECT
            'report'::text AS "source_type",
            reports.id,
            reports.description,
            reports.report_time,
            reports.report_category_id,
            reports.latitude,
            reports.longitude,
            reports.street_name,
            reports.city,
            reports.state,
            reports.country,
            reports.postcode,
            reports.created_at,
            reports.updated_at,
            reports.location,
            reports.invisible,
            reports.user_id,
            reports.crime_type_id,
            report_categories.violent
          FROM reports
            JOIN report_categories ON reports.report_category_id = report_categories.id
          WHERE report_time > (now() - interval '2 months')
        )
        UNION ALL
        (
          SELECT
            'crime_datum'::text AS "source_type",
            crime_data.id,
            crime_data.note AS "description",
            crime_data.occurred_at AS "report_time",
            crime_types.report_category_id,
            ST_Y(crime_data.location::GEOMETRY) AS "latitude",
            ST_X(crime_data.location::GEOMETRY) AS "longitude",
            crime_data.address AS "street_name",
            cities.name AS "city",
            cities.state AS "state",
            cities.country AS "country",
            crime_data.postcode,
            crime_data.reported_at AS "created_at",
            crime_data.reported_at AS "updated_at",
            crime_data.location,
            'false'::boolean AS "invisible",
            NULL AS "user_id",
            crime_data.crime_type_id,
            crime_types.violent
          FROM crime_data
            JOIN crime_types ON crime_data.crime_type_id = crime_types.id
            JOIN cities ON crime_data.city_id = cities.id
          WHERE crime_data.occurred_at > (now() - interval '2 months')
        );

      CREATE INDEX recent_reports_location_gix
        ON public.#{RecentReport.table_name}
        USING gist
        (location);

      CREATE INDEX recent_reports_location_country_state_city_gix
        ON public.recent_reports
        USING gist
        (location, country, state, city);

      CREATE INDEX recent_reports_country_state_city_idx
        ON public.#{RecentReport.table_name}(country, state, city);

      CREATE UNIQUE INDEX recent_reports_type_id_uix
        ON public.#{RecentReport.table_name}(source_type, id);
    SQL
  end

  def down
    execute <<-SQL
      DROP MATERIALIZED VIEW IF EXISTS #{RecentReport.table_name};
      DROP EXTENSION btree_gist;
      DROP EXTENSION kmeans;
    SQL
  end
end
