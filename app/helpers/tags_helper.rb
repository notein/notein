module TagsHelper

  def build_add_tag_url(params, add_tag)
    if params[:tag] and params[:tags]
      value = "/tags/" + build_tag_list(params[:tag], params[:tags]).join("/") + "/" + add_tag
    elsif params[:tag]
      value = "/tags/" + params[:tag] + "/" + add_tag
    end
    
    if params[:username]
      return "/" + params[:username] + value
    else
      return value
    end
  end
  
  def build_tag_url(params, add_tag, current_user = nil)
    if params[:username]
      return "/" + params[:username] + "/tags/" + add_tag
    elsif current_user
      return "/" + current_user.username + "/tags/" + add_tag
    else
      return "/tags/" + add_tag
    end
  end

end