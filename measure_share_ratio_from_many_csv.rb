require 'csv'
require 'pp'
require 'logger'
require 'set'

def main
  measure_share_ratio
end
class Array
  # 要素の平均を算出する
  def avg
    inject(0.0){|r,i| r+=i }/size
  end
  # 要素の分散を算出する
  def variance
    a = avg
    inject(0.0){|r,i| r+=(i-a)**2 }/size
  end
  # 標準偏差を算出する
  def standard_deviation
    Math.sqrt(variance)
  end
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
    @node_a = Set.new
    @node_b = Set.new
    CSV.foreach(input_filename) do |row|
      if row.size>2
        array_of_a = split_comma_to_array(row[1])
        # if row[2]
        array_of_b  = split_comma_to_array(row[2])
        # pp array_of_b
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
        array_of_a.each{|a|
          @node_a<<a
        }
        array_of_b.each{|b|
          @node_b<<b
        }
      end
    end
  end
  attr_accessor :pivot
  attr_accessor :lang_a_b
  attr_accessor :lang_b_a
  attr_accessor :lang_a_p
  attr_accessor :lang_b_p
  attr_accessor :lang_p_a
  attr_accessor :lang_p_b
  attr_accessor :node_a
  attr_accessor :node_b
end

class Answer
  def initialize(answer_filename)
    @answer = {}
    CSV.foreach(answer_filename) do |row|
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


#3言語辞書データと答えの辞書データを入力
#pivotの共有率を返す
def measure_share_ratio
  language="JaToEn_EnToDe"
  # language="Zh_Uy_Kz"
  input_filename="partition_graph1210/"+language+"/"+language+"_subgraph_"

  # answer_filename="answer/#{$stdin.gets.chomp}.csv"
  answer_filename="answer/Ja_De.csv"
  # answer_filename="answer/Mnk_Zsm.csv"
  # answer_filename="answer/answer_UK_1122.csv"
  max=239
  # max=1180
  answer = Answer.new(answer_filename)
  answer_hash = {}#hash
  CSV.foreach(answer_filename) do |answer_row|
    answer_hash[answer_row[0]]=answer_row[1..-1]
  end


  1.upto(max) do |i|
    transgraph = Transgraph.new(input_filename+"#{i}.csv")
    pivot_connected=Set.new
    pivot_share=Set.new
    raw_output={}

    pivot_connected_num=Array.new #答えのA-Bペアのどちらかと繋がっているpivotの数
    pivot_share_num=Array.new #答えのA-Bペアの両方と繋がっているpivotの数
    share_ratio=Array.new #pivotの共有率
    transgraph.node_a.each{|node_a|
      transgraph.node_b.each{|node_b|

        pivot_connected=transgraph.lang_a_p[node_a] + transgraph.lang_b_p[node_b]#setの和部分
        pivot_share=transgraph.lang_a_p[node_a] & transgraph.lang_b_p[node_b]#setの共通部分
        pivot_connected_num.push(pivot_connected.size)#answer_valueとanswer_keyと接続しているpivot
        pivot_share_num.push(pivot_share.size)
        share_ratio.push(pivot_share_num[-1].fdiv(pivot_connected_num[-1])) #pivotの共有率

        # pp "共有率:#{pivot_share_num[-1]}/#{pivot_connected_num[-1]}"
        # puts share_ratio.inject(0.0){|r,i| r+=i }/share_ratio.size
        # pp pivot_share_num[-1].fdiv(pivot_connected_num[-1])
      }
    }

    pivot_connected_num_answer=Array.new #答えのA-Bペアのどちらかと繋がっているpivotの数
    pivot_share_num_answer=Array.new #答えのA-Bペアの両方と繋がっているpivotの数
    share_ratio_answer=Array.new #pivotの共有率
    answer.answer.each{|answer_key, answer_values|
      answer_values.each{|answer_value|#全てのanswerのA-Bについて走査
        # pp "#{answer_key} exists"
        if transgraph.lang_a_b.has_key?(answer_key)#同じ日本語の見出し語があるか
          if transgraph.lang_a_b[answer_key].include?(answer_value)#同じドイツ語の単語があるか
            # pp "#{answer_key} & #{answer_value} exists"
            pivot_connected=transgraph.lang_a_p[answer_key] + transgraph.lang_b_p[answer_value]#setの和部分
            pivot_share=transgraph.lang_a_p[answer_key] & transgraph.lang_b_p[answer_value]#setの共通部分
            pivot_connected_num_answer.push(pivot_connected.size)#answer_valueとanswer_keyと接続しているpivot
            pivot_share_num_answer.push(pivot_share.size)
            # pp pivot_share_num[-1].fdiv(pivot_connected_num_answer[-1])

            share_ratio_answer.push(pivot_share_num_answer[-1].fdiv(pivot_connected_num_answer[-1])) #pivotの共有率
          else
            # pp "#{answer_key} found but #{answer_value} doent exists"
          end


        end
      }

    }
    if share_ratio_answer.size>0
      # puts "答えデータのピボット共有率"
      # share_ratio_of_answer = share_ratio_answer.inject(0.0){|r,i| r+=i }/share_ratio_answer.size
      # puts share_ratio_of_answer

      # pp share_ratio.avg # puts "トランスグラフ内全ての平均"
      pp share_ratio_answer.avg # puts "答えデータのピボット共有率平均"
      # pp share_ratio_answer
      # pp share_ratio.standard_deviation


      if share_ratio.standard_deviation !=0
        share_ratio_answer.each{|sr_answer|
          # pp sr_answer
          # if sr_answer<share_ratio.avg

          # pp "答えペアのピボット共有率 , 1.でだしたピボット共有率平均"
          # pp sr_answer
          # pp share_ratio.avg
          # pp (sr_answer-share_ratio.avg)
          pp (sr_answer-share_ratio.avg)/share_ratio.standard_deviation
          # end
        }
      else
        # 標準偏差が0ということはすべてのshare_ratioの値が同じとき
        share_ratio_answer.each{|sr_answer|
          puts "0"
        }
      end
    end
  end

end

main
