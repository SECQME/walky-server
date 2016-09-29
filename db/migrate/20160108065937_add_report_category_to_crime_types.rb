class AddReportCategoryToCrimeTypes < ActiveRecord::Migration
  def up
    add_reference :crime_types, :report_category, index: true, foreign_key: true

    CrimeType.connection.schema_cache.clear!
    CrimeType.reset_column_information

    report_category = ReportCategory.where(name: "Others").first
    CrimeType.update_all(report_category_id: report_category.id)

    report_category = ReportCategory.where(name: "Drunk & Disorderly").first
    CrimeType.where(name: "ARMED DRUNKENNESS").update_all(report_category_id: report_category.id)

    report_category = ReportCategory.where(name: "Loitering").first
    CrimeType.where(name: ["STALKING", "LOITERING", "CREEPS", "SIMPLE STALKING"]).update_all(report_category_id: report_category.id)

    report_category = ReportCategory.where(name: "Gangs").first
    CrimeType.where(name: ["GANG RELATED CRIMES"]).update_all(report_category_id: report_category.id)

    report_category = ReportCategory.where(name: "Fights").first
    report_category.update(name: "Assault")
    CrimeType.where(name: ["DRIVEBY SHOOTING", "WEAPONS DISCHARGE"]).update_all(report_category_id: report_category.id)

    report_category = ReportCategory.where(name: "Gun violence").first
    CrimeType.where(name: ["ASSAULT", "BATTERY", "HOMICIDE", "KIDNAPPING", "TERRORISM", "DOMESTIC VIOLENCE", "AGGRAVATED ASSAULT", "AGGRAVATED BATTERY", "ASSAULT WITH WEAPONS", "BATTERY WITH WEAPONS", "DOMESTIC BATTERY", "SIMPLE ASSAULT", "SIMPLE BATTERY", "AGGRAVATED KIDNAPPING"]).update_all(report_category_id: report_category.id)

    report_category = ReportCategory.where(name: "Theft & Robbery").first
    CrimeType.where(name: ["BURGLARY", "CRIMINAL DAMAGE", "LARCENY THEFT", "MOTOR VEHICLE THEFT", "ROBBERY", "STOLEN PROPERTY", "PETTY THEFT", "GRAND THEFT", "VEHICLE THEFT", "LARCENY/THEFT", "THEFT", "MINOR THEFT", "PICKPOCKET", "RETAIL THEFT", "SNATCH THEFT", "VEHICLE DAMAGE", "VEHICLE HIJACKING", "ARMED ROBBERY"]).update_all(report_category_id: report_category.id)

    ReportCategory.delete_all(name: "Molestation")

    report_category = ReportCategory.where(name: "Rape").first
    CrimeType.where(name: ["ARMED CRIM SEXUAL ASSAULT", "CRIM SEXUAL ASSAULT", "SEX OFFENSE", "SEX OFFENSES, FORCIBLE", "SEX OFFENSES", "FORCIBLE", "SEX OFFENSES, NON FORCIBLE", "AGGRAVATED DOMESTIC CRIMINAL SEXUAL ASSAULT", "ARMED CRIM SEXUAL ASSAULT", "CHILD SEXUAL ASSAULT", "DOMESTIC SEX OFFENSES"]).update_all(report_category_id: report_category.id)
  end

  def down
    remove_reference :crime_types, :report_category
  end
end
