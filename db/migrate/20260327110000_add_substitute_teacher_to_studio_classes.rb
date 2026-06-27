class AddSubstituteTeacherToStudioClasses < ActiveRecord::Migration[7.1]
  def up
    if column_exists?(:studio_classes, :substitute_teacher_id)
      remove_column :studio_classes, :substitute_teacher_id
    end
    unless column_exists?(:studio_classes, :substitute_teacher_name)
      add_column :studio_classes, :substitute_teacher_name, :string
    end
  end

  def down
    remove_column :studio_classes, :substitute_teacher_name, if_exists: true
  end
end
