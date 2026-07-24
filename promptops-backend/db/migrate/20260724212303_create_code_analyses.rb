class CreateCodeAnalyses < ActiveRecord::Migration[8.1]
  def change
    create_table :code_analyses do |t|
      t.references :project, null: false, foreign_key: true
      t.string :status
      t.integer :code_quality_score
      t.jsonb :review_payload

      t.timestamps
    end
  end
end
