module ApplicationHelper
  
  def current_site?(controller_name, action_name)
    controller.controller_name == controller_name and controller.action_name == action_name
  end

  def search_text(params)    
    if params[:tag] and params[:tags]
      tag_list = build_tag_list(params[:tag], params[:tags])
      return tag_list.map{|tag| "#" + tag + " "}.join
    elsif params[:tag]
      return "#" + params[:tag]
    elsif params[:term]
      return params[:term]
    else
      return ""
    end
  end
  
  def search_placeholder(params)
    if params[:username]
      return "Search in #{params[:username]}..."
    else
      return "Search..."
    end
  end
  
  def build_tag_list(tag = nil, tags = nil)
    tag_list = []
    tag_list << tag if tag
    if tags && tags.include?("/")
      tag_list.concat(tags.split("/"))
    else
      tag_list << tags
    end
    return tag_list
  end
  
  def emojify(value)
    h(value).to_str.gsub(/:([\w+-]+):/) do |match|
      if emoji = Emoji.find_by_alias($1)
        %(<img alt="#$1" src="#{image_path("emoji/#{emoji.image_filename}")}" style="vertical-align:middle" width="20" height="20" />)
      else
        match
      end
    end.html_safe if value.present?
  end
  
  def random_bright_color
    (0..2).map{"%0x" % (rand * 0x80 + 0x80)}.join
  end
  
  
end
