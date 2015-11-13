require 'csv'
require 'pp'
require 'logger'
require 'set'

def main
  puts "A-P辞書のcsvファイル"
  filename1="share_ratio/#{$stdin.gets.chomp}"
  puts "A-B辞書のcsvファイル"
  filename2="share_ratio/#{$stdin.gets.chomp}"

  log = Logger.new("share_ratio/share_ratio_error.log")
  measure_share_ratio(filename1,filename2)

end

#3つのノード数とファイル名を入力,1つのファイル出力
def measure_share_ratio(filename1,filename2)

  in1 = {}#hash
  #"source1","pivot1,pivot2,pivot3"
  CSV.foreach(filename1) do |in1_row|
    in1[in1_row[0]]=in1_row[1..-1]
  end

  in2 = {}#hash
  #"source1","target1,target2,target3"
  CSV.foreach(filename2) do |in2_row|
    in2[in2_row[0]]=in2_row[1..-1]
  end

  common_key1=0
  common_key2=0
  in1_only_key=0
  in2_only_key=0

  in1.each { |in1_row|
  #pp in1_row[0]
    if in2.has_key?(in1_row[0])
      # pp "exist"
      common_key1=common_key1+1
    else
      # pp "does not exist"
      in1_only_key=in1_only_key+1
    end
  }

  in2.each { |in2_row|
    # pp in2_row[0]
    if in1.has_key?(in2_row[0])
      # pp "exist"
      common_key2=common_key2+1
    else
      pp "#{in2_row[0]}does not exist"
      in2_only_key=in2_only_key+1
    end
  }
  pp in1.size
  pp in2.size
  pp common_key1
  pp common_key2
  pp in1_only_key
  pp in2_only_key

end

main
