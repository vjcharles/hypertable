class RangeServersController < ApplicationController
  include GoogleChart
  
  def index
    @time_intervals = FileReader::TIME_INTERVALS
    range_servers = RangeServer.get_stats

    @data_types = range_servers[0].get_data_names.sort
    @sort_types = ["name", "data"] 
    
    @selected_sort = params[:sort_by] || "name" # default if no params in url
    @selected_data = params[:data_type] || @data_types[0]
    @timestamp_index = params[:time_interval].blank? ? 2 : params[:time_interval].to_i # default interval at index 2 (10 minutes has interesting test data)
    
    sorted_range_servers = RangeServer.sort(range_servers, @selected_sort, @selected_data, @timestamp_index)
    data_array = RangeServer.get_all_data(sorted_range_servers, @selected_data, @timestamp_index)
    @chart = generate_chart(data_array, @selected_sort, @timestamp_index, @selected_data, @time_intervals, sorted_range_servers)
    
    @json_map = json_map(@chart)
        
    @html_map = generate_html_map(@json_map, sorted_range_servers)
    
    #todo: this selects the first table's timestamp.
    @time = Time.at sorted_range_servers.first.timestamps[@timestamp_index] / 10 ** 9
    
    
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  def show
    @time_intervals = FileReader::TIME_INTERVALS
    @range_server = RangeServer.get_stat params[:id]
  end
    
end
