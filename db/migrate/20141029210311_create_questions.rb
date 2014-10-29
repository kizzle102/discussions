class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.text :content
      t.references :discussion, index: true

      t.timestamps
    end
  end
end
