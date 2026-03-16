class CreateRecipes < ActiveRecord::Migration[8.1]
  def change
    create_table :recipes do |t|
      t.string :id_from_api
      t.string :name
      t.string :alternate_name
      t.text :instructions
      t.string :img_url
      t.references :category, null: false, foreign_key: true
      t.references :area, null: false, foreign_key: true

      t.timestamps
    end
  end
end
