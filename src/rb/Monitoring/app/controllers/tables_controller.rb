class TablesController < ApplicationController
  use_google_charts
  def index
    tables = Table.get_stats
    data_names = tables[0].get_data_names
    @sort_types = ["name"] + data_names

    #todo: get data file to contain types of intervals
    @time_interval = [1, 5, 10] #hard coded time intervals 
    
    @selected_sort = params[:sort_by] || "name" # default if no params in url
    @selected_index = params[:time_interval].blank? ? 2 : params[:time_interval].to_i # default interval at index 2 (10 seconds has interesting test data)
    puts params[:time_interval]

    @time_interval.find(@selected_index)
    
    sorted_tables = Table.sort(tables, @selected_sort, @selected_index)

    data_array = Table.get_all_data(sorted_tables, @selected_sort, @selected_index)

    @chart = generate_chart(data_array, @selected_sort, @time_interval, @selected_index, sorted_tables)
    
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  #todo: clean this up. naually generated google chart (probably deleting google chart plugin soon...not needed)
  def generate_chart(data_array, selected_sort, time_interval, selected_index, sorted_tables)
    # handcrafted googlechart url
    chart = "http://chart.apis.google.com/chart?" + 
      "cht=bhs&" + 
      "chts=FF0000,15&" +
      "chs=500x300&" + # size
      "chd=t:#{data_array.reverse.join(',')}&" + #data 
      "chds=#{data_array.first},#{data_array.last}&" + # scale
      "chxr=0,#{data_array.first},#{data_array.last}&" + # values to be listed (high and low)
      "chxt=x,y&" + 
      "chxl=1:|#{Table.get_all_names(sorted_tables).reverse.map{|n| n.titleize}.join('|')}&" + #notice the order is reversed, put stat label here
      "chco=FF0000&"

    #special sort by name shows bytes read and written
    if selected_sort == "name"
      chart = chart + "chtt=Sorted by Table Name, showing bytes read|every " + (time_interval[selected_index] > 1 ? "#{time_interval[selected_index]} seconds" : 'second') + "&" #title
    else    
      chart = chart + "chtt=#{selected_sort.titleize}|Averaged by #{time_interval[selected_index]} second" + (time_interval[selected_index] > 1 ? 's' : '') + "&" #title
    end
    chart
  end

end
