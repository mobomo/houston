module MailerHelper

  def schedule_hours_cells(values, bgcolor)
    values.each_with_index.map do |v, i|
      v = '' if v == 0

      if i == 1
        "<td align='center' bgcolor='#{bgcolor}'><b>#{v}</b></td>".html_safe
      else
        "<td align='center' bgcolor='#{bgcolor}'>#{v}</td>".html_safe
      end
    end.join("\n").html_safe
  end

end
