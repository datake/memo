require 'csv'
require 'pp'
require 'logger'
require 'set'

def main
  # get_zuk_answer
  measure_share_ratio
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
      row[1] = row[1].gsub(/؛/, ',')
      #
      row[2] = row[2].gsub(/؛/, '\,')
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

#ZUKの答えデータを取得する
def get_zuk_answer
  input_filename="share_ratio/Z_U_K.csv"
  answer_filename="answer_UK.csv"

  transgraph = Transgraph.new(input_filename)
  answer_UK={}
  transgraph.lang_a_b.each{|key, value_arr|
    value_arr.each{|value|
      if key==value
        unless answer_UK.include?(key)
          answer_UK[key]=value
        end
      end
    }
    # if transgraph.lang_b_a.has_key?(key)
    #   unless answer_UK.include?(key)
    #     answer_UK[key]=key
    #   end
    # end
  }
  File.open(answer_filename, "w") do |out|
    answer_UK.each{|key, value|
      out.puts "#{key},#{key}"
    }
  end
end

#3言語辞書データと答えの辞書データを入力
#pivotの共有率を返す
def measure_share_ratio
  input_filename="share_ratio/Z_U_K.csv"
  answer_filename="answer_UK.csv"


  transgraph = Transgraph.new(input_filename) #{"pivot"=>["a", "b"]}
  #pp transgraph.lang_a_p
  answer = Answer.new(answer_filename)

  #答えとなるペアそれぞれについて、以下の3つを出す
  #answer_key_value_pair=Array.new
  pivot_connected=Set.new
  pivot_share=Set.new
  raw_output={}
  pivot_connected_num=Array.new #答えのA-Bペアのどちらかと繋がっているpivotの数
  pivot_share_num=Array.new #答えのA-Bペアの両方と繋がっているpivotの数
  share_ratio=Array.new #pivotの共有率
  # File.open(answer_filename, "w") do |out|
  answer.answer.each{|answer_key, answer_values|
    answer_value=answer_values[0]

    if transgraph.lang_a_b.has_key?(answer_key)#同じ日本語の見出し語があるか
      if transgraph.lang_a_b[answer_key].include?(answer_value)#同じドイツ語の単語があるか
        pivot_connected=transgraph.lang_a_p[answer_key] + transgraph.lang_b_p[answer_value]#setの和部分
        pivot_share=transgraph.lang_a_p[answer_key] & transgraph.lang_b_p[answer_value]#setの共通部分

        pivot_connected_num.push(pivot_connected.size)
        pivot_share_num.push(pivot_share.size)

        if raw_output.has_key?("#{pivot_share_num[-1]}/#{pivot_connected_num[-1]}")
          raw_output["#{pivot_share_num[-1]}/#{pivot_connected_num[-1]}"] = raw_output["#{pivot_share_num[-1]}/#{pivot_connected_num[-1]}"]+1
        else
          raw_output["#{pivot_share_num[-1]}/#{pivot_connected_num[-1]}"] = 1
        end
        share_ratio.push(pivot_share_num[-1].fdiv(pivot_connected_num[-1])) #pivotの共有率
        pp "ウイグル語が#{answer_key}でカザフ語が#{answer_value}の際の共有率:#{share_ratio[-1]}(#{pivot_share_num[-1]}/#{pivot_connected_num[-1]})"
        pp "↓分子"
        pp pivot_share
        pp "↓分母:"
        pp pivot_connected
        # pp pivot_connected
        # pp pivot_share
        # end
      else
        # pp "#{answer_key} & #{answer_value} doesnt exists"
      end

    else
      pp "error:1"
    end

  }
  # end
  puts share_ratio.inject(0.0){|r,i| r+=i }/share_ratio.size
  pp raw_output.sort {|(k1, v1), (k2, v2)| v2 <=> v1 }
end




main
