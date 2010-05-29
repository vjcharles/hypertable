# RRDtool backed model
class RangeServer 
  #class methods from module
  extend FileReader
  
  PATH_TO_FILE = "../../../run/monitoring/"
  ORIGINAL_FILE_NAME = "rs_stats.txt"
  COPY_FILE_NAME = "copy_of_#{@orig_file_name}"
  
  disk_read_KBps = {:type => :B, :stats => [:disk_read_KBps, :disk_write_KBps]}
  disk_read_rate = {:type => :B, :stats => [:disk_read_rate, :disk_write_rate]}
  net_recv_KBps = {:type => :B, :stats => [:net_recv_KBps, :net_send_KBps]}
  disk_read_KBps = {:type => :B, :stats => [:disk_read_KBps, :disk_write_KBps]}

  bytes_read = {:type => :B, :stats => [:bytes_read, :bytes_written]}
  query_cache_accesses = {:type => :B, :stats => [:query_cache_accesses, :query_cache_hits]}
  loadavg_0 = {:type => :B, :stats => [:loadavg_0, :loadavg_1, :loadavg_2]}
  cells_read = {:type => :B, :stats => [:cells_read, :cells_written]}
  scans = {:type => :B, :stats => [:scans, :syncs]}
  block_cache_accesses = {:type => :B, :stats => [:block_cache_accesses, :block_cache_hits]}

  #data structure to determine graph types, and what graphs to display.
  STATS_KEY = {
    #type A
    :disk_available => {:type => :A, :stats => [:disk_available, :disk_used]},
    :mem_used => {:type => :A, :stats => [:mem_used, :mem_total]},
    :query_cache_available_memory => {:type => :A, :stats => [:query_cache_available_memory, :query_cache_max_memory]},    
    :block_cache_available_memory => {:type => :A, :stats => [:block_cache_available_memory, :block_cache_max_memory]},
    
    #type B
    :disk_read_KBps => disk_read_KBps,
    :disk_write_KBps => disk_read_KBps,
    
    :disk_read_rate => disk_read_rate,
    :disk_write_rate => disk_read_rate,  
  
    :net_recv_KBps => net_recv_KBps,
    :net_send_KBps => net_recv_KBps,  
  
    :bytes_read => bytes_read,
    :bytes_written => bytes_read,
  
    :query_cache_accesses => query_cache_accesses,
    :query_cache_hits => query_cache_accesses,

    :loadavg_0 => loadavg_0,
    :loadavg_1 => loadavg_0, 
    :loadavg_2 => loadavg_0, 
    
    :cells_read => cells_read,
    :cells_written => cells_read, 

    :scans => scans,
    :syncs => scans, 

    :block_cache_accesses => block_cache_accesses,
    :block_cache_hits => block_cache_accesses, 

    # TYPE C
    :vm_size => {:type => :C, :stats => [:vm_size]},
    :vm_resident => {:type => :C, :stats => [:vm_resident]},
    :updates => {:type => :C, :stats => [:updates]},
    :cpu_pct => {:type => :C, :stats => [:cpu_pct]}
  }


  def self.get_stat_types
    STATS_KEY.keys.sort {|a,b| a.to_s <=> b.to_s}.map {|d| d.to_s}
  end
  
  def self.get_chart_type stat
    stat = stat.to_sym
    STATS_KEY[stat]
  end
  
  def initialize (id=nil)
    @id = id
    @data = {}
  end
  
  attr_accessor :id, 
                :timestamps, 
                :data
  
  def get_stat_names
    return [] unless self.data != {}
    names = self.data.keys.map {|k| k.to_s }
  end
  
  alias name id
end
