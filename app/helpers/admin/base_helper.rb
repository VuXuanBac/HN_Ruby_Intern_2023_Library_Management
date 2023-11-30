module Admin::BaseHelper
  def format_time_ago string
    bad_words = [
      t("datetime.less_than"),
      t("datetime.about"),
      t("datetime.over"),
      t("datetime.almost")
    ]

    bad_words.each do |bad|
      string.gsub!("#{bad} ", "")
    end
    string
  end

  def time_ago date
    format_time_ago time_ago_in_words(date) if date
  end

  def localize_date datetime, format = :long
    l(datetime.to_date, format:) if datetime
  end

  def get_image obj, attribute = :avatar
    image = obj&.public_send(attribute)
    image&.attached? ? image : Settings.public_send("default_#{attribute}_path")
  end

  def get_link item, resource, for_text: :name, class: nil
    text = item&.public_send(for_text)
    link_to_if item, text,
               (send("admin_#{resource}_path", item) if item),
               class:, title: text
  end

  def render_table_header title, name = nil
    current = request.params[:sort] == name.to_s
    is_desc = params[:style]&.downcase == "desc"
    style = (is_desc ? :desc : :asc) if current
    new_style = style == :asc ? :desc : :asc
    link = url_for(request.params.merge(style: new_style, sort: name))
    render "admin/shared/table_header", style:,
            sortable: name.present?, link:, title:
  end

  def navigate_to list: false, path: nil, path_text: nil, replace: false
    link_class = "btn btn-info mb-3"
    data = {turbo_action: :replace} if replace

    if path
      link_to path_text, path,
              class: link_class, data:
    elsif list
      link_to t("admin.misc.to_list"), url_for(action: :index),
              class: link_class, data:
    else
      link_to t("admin.misc.back"), "javascript:history.back()",
              class: link_class, data:
    end
  end
end
