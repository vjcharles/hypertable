class TablesController < ApplicationController
  def index
    @sort_types = ["hostname", "reverse_date"]
    @time_interval = [1, 5, 10]
    
    @selected_sort = params[:sort_by] || "hostname" # hostname is default if no params in url
    @selected_interval = params[:time_interval] || 1 # interval default

    @graph = "[graph!]"
    
    respond_to do |format|
      format.html # index.html.erb
    end
  end

end
