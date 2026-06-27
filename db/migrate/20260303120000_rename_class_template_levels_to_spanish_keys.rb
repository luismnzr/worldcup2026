class RenameClassTemplateLevelsToSpanishKeys < ActiveRecord::Migration[7.1]
  def up
    ClassTemplate.where(level: %w[beginner intermediate]).update_all(level: "multinivel")
    ClassTemplate.where(level: "advanced").update_all(level: "int_avanzado")
  end

  def down
    ClassTemplate.where(level: "multinivel").update_all(level: "beginner")
    ClassTemplate.where(level: "int_avanzado").update_all(level: "advanced")
  end
end
