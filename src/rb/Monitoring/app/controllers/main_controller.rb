class MainController < ApplicationController
  use_google_charts
  
  def index
    @google_chart_test = google_charts_test
    # @rrd_google_chart_test = rrd_google_charts_test
    
    
    
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  
  ## utility method
  # GC4R example
  def google_charts_test
    # # 10. and two more, right and second x axis
    dataset1 = GoogleChartDataset.new :data => [10,50,4,10,16], :color => 'FF0000', :title => 'Java'
    dataset2 = GoogleChartDataset.new :data => [99, 81, 25, 54, 80], :color => '0000FF', :title => 'Ruby'
    data = GoogleChartData.new :datasets => [dataset1, dataset2]
    axis = GoogleChartAxis.new :axis  => [GoogleChartAxis::LEFT, GoogleChartAxis::BOTTOM,  GoogleChartAxis::RIGHT, GoogleChartAxis::BOTTOM]
    chart = GoogleLineChart.new :width => 300, :height => 200, :title => ['Java vs. Ruby', 'Montly Job Opportunities']
    chart.data = data
    chart.axis = axis
    # 11. so far so good, now i want a bar chart
    # dataset1 = GoogleChartDataset.new :data => [10,50,4,10,16], :color => 'FF0000', :title => 'Java'
    # dataset2 = GoogleChartDataset.new :data => [99, 81, 25, 54, 80], :color => '0000FF', :title => 'Ruby'
    # data = GoogleChartData.new :datasets => [dataset1, dataset2]
    # axis = GoogleChartAxis.new :axis  => [GoogleChartAxis::LEFT, GoogleChartAxis::BOTTOM,  GoogleChartAxis::RIGHT, GoogleChartAxis::BOTTOM]
    # @chart = GoogleBarChart.new :width => 300, :height => 200, :title => ['Java vs. Ruby', 'Montly Job Opportunities']
    # @chart.data = data
    # @chart.axis = axis
    # 12. or nice 3d pie chart
    # dataset1 = GoogleChartDataset.new :data => 50, :color => 'FF0000', :title => 'Java'
    # dataset2 = GoogleChartDataset.new :data => 90, :color => '0000FF', :title => 'Ruby'
    # data = GoogleChartData.new :datasets => [dataset1, dataset2]
    # @chart = GooglePieChart.new :width => 400, :height => 200, :title => ['Java vs. Ruby', 'Montly Job Opportunities'],
    # :chart_type  => GooglePieChart::PIE_3D
    # @chart.data = data
    ### end example graph
    return chart
  end
  
  def rrd_google_charts_test
    chart = GoogleLineChart.new :width => 400, :height => 200, :title => ["dataset 1", "dataset 2"]#, :chart_type => GooglePieChart::PIE_3D
    dataset1 = GoogleChartDataset.new :data => get_rrd_data("vtest.rrd", 920804400, 920808000), :color => "FF0000", :title => "dataset 1"
    dataset2 = GoogleChartDataset.new :data => get_rrd_data("vtest.rrd", 920804400, 920808000), :color => "0000FF", :title => "dataset 2"
    data = GoogleChartData.new :datasets => [dataset1, dataset2] 
    axis = GoogleChartAxis.new :axis  => [GoogleChartAxis::LEFT, GoogleChartAxis::BOTTOM,  GoogleChartAxis::RIGHT, GoogleChartAxis::BOTTOM]
    chart.data = data   
    return chart
  end  
    
  
  def get_rrd_data(rrd, start_time, end_time)
    #todo: put require in a new initializers file
    require "RRD"

    name = "vtest"
    path = "public/rrd/"
    rrd = "#{path}#{name}.rrd"
    # start_time = 920804400
    # end_time = 920808000

    puts "fetching data from #{rrd}"
    (fstart, fend, names, data) = RRD.fetch(rrd, "--start", start_time, "--end", end_time, "AVERAGE")
    # puts "weeee", fstart, fend, names, data, "wooo"
    return data
    #todo: data needs to be sanitized for gcharts
    # [1,5]
    end

  
  
end
