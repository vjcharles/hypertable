class TablesController < ApplicationController
  include GoogleChart
  
  def index
    tables = Table.get_stats
    @data_types = tables[0].get_data_names.sort
    @sort_types = ["name", "data"] 
    
    #todo: get data file to contain types of intervals
    @time_interval = [1, 5, 10] #hard coded time intervals 
    
    @selected_sort = params[:sort_by] || "name" # default if no params in url
    @selected_data = params[:data_type] || @data_types[0]
    @selected_index = params[:time_interval].blank? ? 2 : params[:time_interval].to_i # default interval at index 2 (10 minutes has interesting test data)
    
    sorted_tables = Table.sort(tables, @selected_sort, @selected_data, @selected_index)
    data_array = Table.get_all_data(sorted_tables, @selected_data, @selected_index)
    @chart = generate_chart(data_array, @selected_sort, @selected_index, @selected_data, @time_interval, sorted_tables)
    
    @json_map = json_map(@chart)
    pp @json_map
    
    @html_map = generate_html_map(@json_map, sorted_tables)
    
    respond_to do |format|
      format.html # index.html.erb
    end
  end

end
