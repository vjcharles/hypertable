# RRDtool backed model
class RangeServer 
  #class methods from module
  extend FileReader
  
  PATH_TO_FILE = "../../../run/monitoring/"
  ORIGINAL_FILE_NAME = "rs_stats.txt"
  COPY_FILE_NAME = "copy_of_#{@orig_file_name}"
  UNIT = FileReader::UNIT
  
  disk_read_KBps = {:type => :B, :stats => [:disk_read_KBps, :disk_write_KBps], :units => UNIT[:kbps]}
  disk_read_rate = {:type => :B, :stats => [:disk_read_rate, :disk_write_rate], :units => UNIT[:rwps]}
  net_recv_KBps = {:type => :B, :stats => [:net_recv_KBps, :net_send_KBps], :units => UNIT[:kbps]}
  disk_read_KBps = {:type => :B, :stats => [:disk_read_KBps, :disk_write_KBps], :units => UNIT[:kbps]}

  bytes_read = {:type => :B, :stats => [:bytes_read, :bytes_written], :units => UNIT[:bytes]}
  query_cache_accesses = {:type => :B, :stats => [:query_cache_accesses, :query_cache_hits], :units => UNIT[:abs]}
  loadavg_0 = {:type => :B, :stats => [:loadavg_0, :loadavg_1, :loadavg_2], :units => UNIT[:loadave]}
  cells_read = {:type => :B, :stats => [:cells_read, :cells_written], :units => UNIT[:abs]}
  scans = {:type => :B, :stats => [:scans, :syncs], :units => UNIT[:abs]}
  block_cache_accesses = {:type => :B, :stats => [:block_cache_accesses, :block_cache_hits], :units => UNIT[:abs]}

  #data structure to determine graph types, and meta data about each element
  STATS_KEY = {
    #type A
    :percent_disk_used => {:type => :A, :stats => [:disk_used, :disk_available], :units => UNIT[:percent]},
    :percent_mem_used => {:type => :A, :stats => [:mem_used, :mem_total], :units => UNIT[:percent]},
    :percent_query_cache_memory_used => {:type => :A, :stats => [:query_cache_available_memory, :query_cache_max_memory], :units => UNIT[:percent]},    
    :percent_block_cache_memory_used => {:type => :A, :stats => [:block_cache_available_memory, :block_cache_max_memory], :units => UNIT[:percent]},
    
    #type B
    :disk_reads => disk_read_KBps,
    :disk_writes => disk_read_KBps,
    
    :disk_read_rate => disk_read_rate,
    :disk_write_rate => disk_read_rate,  
  
    :net_receives => net_recv_KBps,
    :net_sends => net_recv_KBps,  
  
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
    :virtual_machine_size => {:type => :C, :stats => [:vm_size], :units => UNIT[:kb]},
    :virtual_machine_resident => {:type => :C, :stats => [:vm_resident], :units => UNIT[:kb]},
    :updates => {:type => :C, :stats => [:updates], :units => UNIT[:ab]},
    :cpu_percent => {:type => :C, :stats => [:cpu_pct], :units => UNIT[:percent]},
    :block_cache_max_memory => {:type => :C, :stats => [:block_cache_max_memory], :units => UNIT[:bytes]},
    
    # also have type A percent from these
    :disk_used => {:type => :C, :stats => [:disk_used], :units => UNIT[:kb]},
    :mem_used => {:type => :C, :stats => [:mem_used], :units => UNIT[:kb]},
    :query_cache_available_memory => {:type => :C, :stats => [:query_cache_available_memory], :units => UNIT[:kb]},
    :query_cache_max_memory => {:type => :C, :stats => [:query_cache_max_memory], :units => UNIT[:kb]},
    :block_cache_available_memory => {:type => :C, :stats => [:block_cache_available_memory], :units => UNIT[:kb]},
    :block_cache_max_memory => {:type => :C, :stats => [:block_cache_max_memory], :units => UNIT[:kb]},

    #todo: immutable 
    :disk_available => {:type => :C, :stats => [:disk_available], :units => UNIT[:kb]},
    :mem_total => {:type => :C, :stats => [:mem_total], :units => UNIT[:kb]}
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
