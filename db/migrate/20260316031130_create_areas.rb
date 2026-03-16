class CreateAreas < ActiveRecord::Migration[8.1]
  def change
    create_table :areas do |t|
      t.string :id_from_api
      t.string :name

      t.timestamps
    end
  end
end
