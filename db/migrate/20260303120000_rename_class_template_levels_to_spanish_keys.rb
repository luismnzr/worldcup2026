class RenameClassTemplateLevelsToSpanishKeys < ActiveRecord::Migration[7.1]
  # Migración heredada del boilerplate. La tabla `class_templates` ya no existe
  # en este proyecto (World Cup 2026), así que la guardamos para que sea un
  # no-op cuando la tabla no está presente y `db:migrate` corra desde cero.
  def up
    return unless table_exists?(:class_templates)

    execute <<~SQL
      UPDATE class_templates SET level = 'multinivel' WHERE level IN ('beginner', 'intermediate');
      UPDATE class_templates SET level = 'int_avanzado' WHERE level = 'advanced';
    SQL
  end

  def down
    return unless table_exists?(:class_templates)

    execute <<~SQL
      UPDATE class_templates SET level = 'beginner' WHERE level = 'multinivel';
      UPDATE class_templates SET level = 'advanced' WHERE level = 'int_avanzado';
    SQL
  end
end
