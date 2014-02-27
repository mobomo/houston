class CreateLeaveRequests < ActiveRecord::Migration
  def change
    create_table :leave_requests do |t|
      t.references :user, index: true
      t.integer    :approved_by
      t.datetime   :start_date
      t.datetime   :end_date
      t.boolean    :approved
      t.datetime   :approved_date
      t.datetime   :start_date
      t.text       :reason_for_leaving
      t.text       :checked_with_supervisor

      t.timestamps
    end
  end
end
