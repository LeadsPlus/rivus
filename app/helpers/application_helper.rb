module ApplicationHelper
  # Show flash messages using Twitter-Bootstrap's "alert" elements.
  # @return [String]
  def bootstrap_flash
    flash_messages = []
    flash.each do |type, message|
      type = :success if type == :notice
      type = :error   if type == :alert
      text = content_tag(:div, link_to("x", "#", :class => "close", "data-dismiss" => "alert") + message, :class => "alert fade in alert-#{type}")
      flash_messages << text if message
    end
    flash_messages.join("\n").html_safe
  end

  def gravatar(email)
    return '' unless email
    image_tag Gravatar.new(email).url, class: 'gravatar', alt: email
  end
end
