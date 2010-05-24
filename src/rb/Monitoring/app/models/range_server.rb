# RRDtool backed model
class RangeServer 
  #class methods from module
  extend FileReader
  
  PATH_TO_FILE = "../../../run/monitoring/"
  ORIGINAL_FILE_NAME = "rs_stats.txt"
  COPY_FILE_NAME = "copy_of_#{@orig_file_name}"
  
  def initialize (id=nil)
    @id = id
    @data = {}
  end
  
  attr_accessor :id, 
                :timestamps, 
                :data
  
  def get_data_names
    return [] unless self.data != {}
    names = self.data.keys.map {|k| k.to_s }
  end

  # # demonstrates retrieval and graph generation from an RRDtool db
  # def self.rrd_test
  #   #todo: put require in a new initializers file
  #   require "RRD"
  # 
  #   name = "vtest"
  #   path = "public/rrd/"
  #   rrd = "#{path}#{name}.rrd"
  #   start_time = 920804400
  #   end_time = 920808000
  # 
  #   puts "fetching data from #{rrd}"
  #   (fstart, fend, data) = RRD.fetch(rrd, "--start", start_time, "--end", end_time, "AVERAGE")
  #   puts "got #{data.length} data points from #{fstart} to #{fend}"
  #   puts
  # 
  #   puts "generating graph #{name}.png"
  #   RRD.graph(
  #      "#{path}#{name}.png",
  #       "--title", " vRubyRRD Demo", 
  #       "--start", start_time,
  #       "--end", end_time,
  #       "DEF:myspeed=#{rrd}:speed:AVERAGE",
  #       "LINE2:myspeed#FF0000")
  #   return "#{name}.png"        
  # end  
end
