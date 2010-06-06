# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  def find_largest(array)
    array.flatten.sort.last
  end

  def find_smallest(array)
    array.flatten.sort.first
  end
  
  #to use helper methods in controller
  def help
    Helper.instance
  end

  class Helper
    include Singleton
    include ActionView::Helpers::NumberHelper
  end
  
  # retrieval and graph generation from RRDtool dbs
  PATH_TO_FILE = "../../../run/monitoring/"
  VERSION_NUMBER = 0
  
  def get_all_rrd_rs_graphs range_server, stat_types
    rrd_name = range_server.name
    
    rrd = "#{PATH_TO_FILE}#{rrd_name}_stats_v#{VERSION_NUMBER}.rrd"
    start_time = 1273511280
    end_time = 1273515237
    
    graphs = []
  
    stat_types.each do |stat_name|
      file_name = "#{rrd_name}_#{stat_name.to_s}"
      puts "fetching data from #{rrd}"
      (fstart, fend, data) = RRD.fetch(rrd, "--start", start_time, "--end", end_time, "AVERAGE")

      puts "got #{data.length} data points from #{fstart} to #{fend}"
      puts
  
      puts "generating graph #{rrd_name}.png"
      RRD.graph(
         "../../../src/rb/Monitoring/public/images/#{file_name}.png",
          "--title", "#{RangeServer.pretty_titleize stat_name}", 
          "--start", start_time,
          "--end", end_time,
          "DEF:cells_read=#{rrd}:cells_read:AVERAGE", 
          "DEF:cells_written=#{rrd}:cells_written:AVERAGE",
          "LINE2:cells_read#FF0000",
          "LINE2:cells_written#00FF00")

      graphs.push "#{file_name}.png"
    end
    
    
    return graphs        
  end
end
