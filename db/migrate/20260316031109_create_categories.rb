class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string :id_from_api
      t.string :name
      t.string :img_url
      t.text :description

      t.timestamps
    end
  end
end
