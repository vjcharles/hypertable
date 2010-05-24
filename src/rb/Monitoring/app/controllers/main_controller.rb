class MainController < ApplicationController

  def index
    @time_intervals = FileReader::TIME_INTERVALS
    #via table data
    @table_timestamps, @table_system_totals = Table.get_system_totals
    
    @rs_timestamps, @rs_system_totals = RangeServer.get_system_totals
    
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  
    
  #not working
  # def get_rrd_data(rrd, start_time, end_time)
  #   #todo: put require in a new initializers file
  #   require "RRD"
  # 
  #   name = "vtest"
  #   path = "public/rrd/"
  #   rrd = "#{path}#{name}.rrd"
  #   # start_time = 920804400
  #   # end_time = 920808000
  # 
  #   puts "fetching data from #{rrd}"
  #   (fstart, fend, names, data) = RRD.fetch(rrd, "--start", start_time, "--end", end_time, "AVERAGE")
  #   return data
  #   #todo: data needs to be sanitized for gcharts ?
  #   # [1,5]
  # end
  
end
