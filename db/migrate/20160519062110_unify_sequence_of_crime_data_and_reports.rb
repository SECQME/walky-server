class UnifySequenceOfCrimeDataAndReports < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE SEQUENCE "common_reports_id_seq";
      SELECT setval('common_reports_id_seq', (SELECT MAX(id) FROM #{CrimeDatum.table_name}));

      ALTER TABLE #{CrimeDatum.table_name}
        ALTER COLUMN id SET DEFAULT nextval('common_reports_id_seq');
      ALTER TABLE #{Report.table_name}
        ALTER COLUMN id SET DEFAULT nextval('common_reports_id_seq');

      UPDATE #{Report.table_name}
        SET id = nextval('common_reports_id_seq');

      DROP SEQUENCE IF EXISTS reports_id_seq;
      DROP SEQUENCE IF EXISTS crime_data_id_seq;
      DROP SEQUENCE IF EXISTS crime_data_id_seq1;
    SQL
  end

  def down
    execute <<-SQL
      ALTER SEQUENCE common_reports_id_seq RENAME TO crime_data_id_seq;

      CREATE SEQUENCE "reports_id_seq";
      SELECT setval('reports_id_seq', (SELECT MAX(id) FROM #{Report.table_name}));
      ALTER TABLE #{Report.table_name}
        ALTER COLUMN id SET DEFAULT nextval('reports_id_seq');
    SQL
  end
end
