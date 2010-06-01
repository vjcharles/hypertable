class TablesController < ApplicationController
  include GoogleChart
  
  def index
    @time_intervals = FileReader::TIME_INTERVALS
    tables = Table.get_stats

    @stat_types = Table.get_stat_types
    @sort_types = ["data", "name"] 
    
    @selected_sort = params[:sort_by] || @sort_types[0] # default if no params in url
    @selected_stat = params[:data_type] || @stat_types[0]
    @timestamp_index = params[:time_interval].blank? ? 2 : params[:time_interval].to_i # default interval at index 2 (10 minutes has interesting test data)
    
    @chart_key = Table.get_chart_type @selected_stat
    sorted_tables = Table.sort(@chart_key, tables, @selected_sort, @selected_stat, @timestamp_index)

    # dynamic charts
    @chart = generate_chart(@chart_key, sorted_tables, @selected_sort, @timestamp_index, @selected_stat)

    @json_map = json_map(@chart)
    @html_map = generate_html_map(@json_map, sorted_tables, @chart_key, @timestamp_index)    
    
    #todo: this selects the first table's timestamp.
    @time = Time.at sorted_tables.first.timestamps[@timestamp_index] / 10 ** 9
    
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  def show
    @time_intervals = FileReader::TIME_INTERVALS
    @table = Table.get_stat params[:id]
  end

end
