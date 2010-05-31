class Table
  # require 'pp'
  # require 'ftools'
  extend FileReader
  
  PATH_TO_FILE = "../../../run/monitoring/"
  ORIGINAL_FILE_NAME = "table_stats.txt"
  COPY_FILE_NAME = "copy_of_#{@orig_file_name}"
  UNIT = FileReader::UNIT
  
  cells_read = {:type => :B, :stats => [:cells_read, :cells_written], :units => UNIT[:abs]}
  bloom_filter_accesses = {:type => :B, :stats => [:bloom_filter_accesses, :bloom_filter_maybes], :units => UNIT[:abs]}
  bloom_filter_memory = {:type => :B, :stats => [:bloom_filter_memory, :block_index_memory, :shadow_cache_memory], :units => UNIT[:bytes]}
  #data structure to determine graph types, and what graphs to display.
  STATS_KEY = {
    :percent_memory_used => {:type => :A, :stats => [:memory_used, :memory_allocated], :units => UNIT[:percent]},
    
    :cells_read => cells_read,
    :cells_written => cells_read,
    
    :bloom_filter_accesses => bloom_filter_accesses,
    :bloom_filter_maybes => bloom_filter_accesses,
    
    :bloom_filter_memory => bloom_filter_memory,
    :block_index_memory => bloom_filter_memory,
    :shadow_cache_memory => bloom_filter_memory,

    :scans => {:type => :C, :stats => [:scans], :units => UNIT[:ab]},
    :bloom_filter_false_positives => {:type => :C, :stats => [:bloom_filter_false_positives], :units => UNIT[:ab]},
    :disk_used => {:type => :C, :stats => [:disk_used], :units => UNIT[:bytes]},
    :memory_used => {:type => :C, :stats => [:memory_used], :units => UNIT[:bytes]}, 

    #todo: immutible
    :memory_alocated => {:type => :C, :stats => [:memory_allocated], :units => UNIT[:bytes]}
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
                :data #data is a hash containing current stats collected.                
                  # :scans, 
                  # :cells_read, 
                  # :bytes_read, 
                  # :cells_written, 
                  # :bytes_written,
                  # :bloom_filter_accesses,
                  # :bloom_filter_maybes,
                  # :bloom_filter_false_positives,
                  # :bloom_filter_memory,
                  # :block_index_memory,
                  # :shadow_cache_memory,
                  # :memory_used,
                  # :memory_allocated,
                  # :disk_used

  def get_stat_names
    return [] unless self.data != {}
    names = self.data.keys.map {|k| k.to_s }
  end
  
  #todo: temp until we have a real table name
  alias name id
  
end

