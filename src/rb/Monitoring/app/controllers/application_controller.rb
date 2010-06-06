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
  
  # # demonstrates retrieval and graph generation from an RRDtool db
  def rrd_test
    #todo: put require in a new initializers file
    require "RRD"
  
    PATH_TO_FILE = "../../../run/monitoring/"
    FILE_NAME = "test"

    rrd = "#{PATH_TO_FILE}#{FILE_NAME}.rrd"
    start_time = 920804400
    end_time = 920808000
  
    puts "fetching data from #{rrd}"
    (fstart, fend, data) = RRD.fetch(rrd, "--start", start_time, "--end", end_time, "AVERAGE")

    "rrdtool graph load.png --start 1273511280 --end 1273515237  DEF:cells_read=rs2_stats_v0.rrd:cells_read:AVERAGE DEF:cells_written=rs2_stats_v0.rrd:cells_written:AVERAGE LINE2:cells_read#FF0000 LINE2:cells_written#00FF00"


    puts "got #{data.length} data points from #{fstart} to #{fend}"
    puts
  
    puts "generating graph #{name}.png"
    RRD.graph(
       "#{path}#{name}.png",
        "--title", " vRubyRRD Demo", 
        "--start", start_time,
        "--end", end_time,
        "DEF:myspeed=#{rrd}:speed:AVERAGE",
        "LINE2:myspeed#FF0000")
    return "#{name}.png"        
  end
end
