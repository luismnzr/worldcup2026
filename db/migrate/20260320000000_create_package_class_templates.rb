class CreatePackageClassTemplates < ActiveRecord::Migration[7.2]
  def change
    create_table :package_class_templates do |t|
      t.references :package, null: false, foreign_key: true
      t.references :class_template, null: false, foreign_key: true

      t.index [ :package_id, :class_template_id ], unique: true, name: "index_pkg_class_tpl_unique"
    end
  end
end
