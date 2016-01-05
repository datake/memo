require 'csv'
require 'pp'
require 'logger'
require 'set'

def main
  #  measure_share_ratio
  # measure_common_words
  measure_common_headword
end

class Transgraph
  def initialize(input_filename)
    @pivot = {}
    @lang_a_b = {}
    @lang_b_a = {}
    @lang_a_p = {}
    @lang_b_p = {}
    @lang_p_a = {}
    @lang_p_b = {}
    CSV.foreach(input_filename) do |row|
      #ZUKのデータはカンマ区切りではなく空白区切りで入ってる
      # row[1] = row[1].gsub(/\s/, ',')
      #
      # row[2] = row[2].gsub(/\s/, '\,')
      # pp row[1]
      array_of_a = split_comma_to_array(row[1])
      array_of_b  = split_comma_to_array(row[2])
      @pivot[row[0]]=[array_of_a,array_of_b] #{"pivot"=>[[a1,a2,a3,..], [b1,b2,b3,..]]}

      @lang_p_a[row[0]] = array_of_a
      @lang_p_b[row[0]] = array_of_b
      array_of_a.each{|a|
        array_of_b.each{|b|
          @lang_a_b[a]=array_of_b #{"a1"=>[b1,b2,b3,..]}とか{"a2"=>[b1,b2,b3,..]}
          @lang_b_a[b]=array_of_a #{"b1"=>"a1,a2,a3,..]"}
          #aやbからみたとき、複数のpivotが対応することがある
          if @lang_a_p.has_key?(a)
            @lang_a_p[a] << row[0] #{"a1"=>Set[pivot1,pivot2,..]}
            # pp @lang_a_p[a]
          else
            @lang_a_p[a]=Set[row[0]] #{"a1"=>Set[pivot]}
          end

          if @lang_b_p.has_key?(b)
            @lang_b_p[b] << row[0] #{"b1"=>Set[pivot1,pivot2,..]}
            # pp @lang_b_p[b]
          else
            @lang_b_p[b]=Set[row[0]] #{"b1"=>"Set[pivot]}
            # pp @lang_b_p[b][0]

          end
        }
      }
    end
  end
  attr_accessor :pivot
  attr_accessor :lang_a_b
  attr_accessor :lang_b_a
  attr_accessor :lang_a_p
  attr_accessor :lang_b_p
  attr_accessor :lang_p_a
  attr_accessor :lang_p_b

  def dispName()
    # print(@name, "¥n")
  end
end

class Answer
  def initialize(answer_filename)
    @answer = {} #{"k1"=>["v1", "v2"]}
    CSV.foreach(answer_filename) do |row|
      #{"answer"=>["a", "b"]}
      @answer[row[0]]=row[1..-1]
    end
  end
  attr_accessor :answer
end

def split_comma_to_array (text)
  # text=text.gsub(/"/, '')
  lang_arr=text.split(",")
  return lang_arr
end

#入力辞書と答えの辞書の見出し語の一致度を計測
def measure_common_headword

  puts "A-P辞書のcsvファイル"
  filename1="common_headword/#{$stdin.gets.chomp}"
  puts "A-B辞書のcsvファイル"
  filename2="common_headword/#{$stdin.gets.chomp}"

  # log = Logger.new("share_ratio/share_ratio_error.log")

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
    if in2.has_key?(in1_row[0])
      common_key1=common_key1+1
    else
      in1_only_key=in1_only_key+1
    end
  }

  in2.each { |in2_row|
    if in1.has_key?(in2_row[0])
      common_key2=common_key2+1
    else
      in2_only_key=in2_only_key+1
    end
  }
  pp "入力辞書1のサイズ"
  pp in1.size
  pp "入力辞書2のサイズ"
  pp in2.size
  pp "入力辞書1と2共有のサイズ"
  pp common_key1
  pp "入力辞書1と2共有のサイズ"
  pp common_key2
  pp "入力辞書1のみのサイズ"
  pp in1_only_key
  pp "入力辞書2のみのサイズ"
  pp in2_only_key

end

main
