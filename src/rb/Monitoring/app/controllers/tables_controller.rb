class TablesController < ApplicationController
  use_google_charts
  def index
    tables = Table.get_stats
    @data_types = tables[0].get_data_names.sort
    @sort_types = ["name", "data"] 
    
    #todo: get data file to contain types of intervals
    @time_interval = [1, 5, 10] #hard coded time intervals 
    
    @selected_sort = params[:sort_by] || "name" # default if no params in url
    @selected_data = params[:data_type] || @data_types[0]
    @selected_index = params[:time_interval].blank? ? 2 : params[:time_interval].to_i # default interval at index 2 (10 seconds has interesting test data)
    
    sorted_tables = Table.sort(tables, @selected_sort, @selected_data, @selected_index)
    pp(sorted_tables)
    data_array = Table.get_all_data(sorted_tables, @selected_data, @selected_index)
    @chart = generate_chart(data_array, @selected_sort, @selected_index, @selected_data, @time_interval, sorted_tables)
    
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  #todo: clean this up. manually generated google chart (probably deleting google chart plugin soon...not needed)
  def generate_chart(data_array, selected_sort, selected_index, selected_data, time_interval, sorted_tables)
    smallest = find_smallest(data_array)
    largest = find_largest(data_array)
    
    # handcrafted googlechart url
    chart = "http://chart.apis.google.com/chart?" + 
      "cht=bhs&" + 
      "chts=FF0000,15&" +
      "chs=500x170&" + # size
      "chd=t:#{data_array.join(',')}&" + #data 
      "chds=#{smallest},#{largest}&" + # scale
      "chxr=0,#{smallest},#{largest}&" + # values to be listed (high and low)
      "chxt=x,y&" + 
      "chxl=1:|#{Table.get_all_names(sorted_tables).reverse.map{|n| "name " + n.titleize}.join('|')}&" + #notice the order is reversed, put stat label here
      "chco=FF0000&"
    if selected_sort == "name"  
      chart = chart + "chtt=#{selected_data.titleize}, Sorted by #{selected_sort.titleize}|every " + (time_interval[selected_index] > 1 ? "#{time_interval[selected_index]} seconds" : 'second') + "&" #title
    else
      chart = chart + "chtt=Sorted by #{selected_data.titleize}|every " + (time_interval[selected_index] > 1 ? "#{time_interval[selected_index]} seconds" : 'second') + "&" #title
    end
    chart
  end
  
  def find_largest(array)
    array.sort.last
  end

  def find_smallest(array)
    array.sort.first
  end

end
