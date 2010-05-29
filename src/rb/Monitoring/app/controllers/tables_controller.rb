class TablesController < ApplicationController
  include GoogleChart
  
  def index
    @time_intervals = FileReader::TIME_INTERVALS
    tables = Table.get_stats

    # @data_types = tables[0].get_data_names.sort
    @data_types = Table.get_data_types
    
    @sort_types = ["name", "data"] 
    
    @selected_sort = params[:sort_by] || "name" # default if no params in url
    @selected_data = params[:data_type] || @data_types[0]
    @selected_index = params[:time_interval].blank? ? 2 : params[:time_interval].to_i # default interval at index 2 (10 minutes has interesting test data)
    
    chart_key = Table.get_chart_type @selected_data

    # sorted_tables = Table.sort(tables, @selected_sort, @selected_data, @selected_index)
    sorted_tables = Table.sort2(chart_key, tables, @selected_sort, @selected_data, @selected_index)
    

    # generic type C chart approch
    @chart = generate_chart(@selected_sort, @selected_index, @selected_data, sorted_tables)
    @json_map = json_map(@chart)
    @html_map = generate_html_map(@json_map, sorted_tables)
    
    
    #todo: this selects the first table's timestamp.
    @time = Time.at sorted_tables.first.timestamps[@selected_index] / 10 ** 9
    
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  def show
    @time_intervals = FileReader::TIME_INTERVALS
    @table = Table.get_stat params[:id]
  end

end
