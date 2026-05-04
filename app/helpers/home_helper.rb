module HomeHelper
  def deadline_icon_class(deadline)
    return "deadline-neutral" if deadline.blank?

    days_left = (deadline.to_date - Date.current).to_i

    if days_left < 0
      "deadline-overdue"
    elsif days_left <= 7
      "deadline-soon"
    else
      "deadline-safe"
    end
  end

  def deadline_status_text(deadline)
    return "No due date" if deadline.blank?

    days_left = (deadline.to_date - Date.current).to_i

    if days_left < 0
      "Overdue #{days_left.abs} days"
    elsif days_left == 0
      "Due today"
    elsif days_left == 1
      "1 day left"
    else
      "#{days_left} days left"
    end
  end
end