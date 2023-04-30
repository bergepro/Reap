module ProjectsHelper
  def grouped_time_regs(assigned_task)
    assigned_task.time_regs
                .joins(membership: :user)
                .group("users.email")
                .pluck("users.email", "SUM(time_regs.minutes)")
  end

  def user_data(email)
    User.find_by(email: email)
  end
end
