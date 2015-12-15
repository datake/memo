require 'csv'
require 'pp'
require 'logger'
require 'set'

def main
  measure_share_ratio
  # measure_share_ratio_zuk
  # measure_share_ratio_jaen_jade
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
def levenshtein_distance(s, t)
  m = s.length
  n = t.length
  return m if n == 0
  return n if m == 0
  d = Array.new(m+1) {Array.new(n+1)}

  (0..m).each {|i| d[i][0] = i}
  (0..n).each {|j| d[0][j] = j}
  (1..n).each do |j|
    (1..m).each do |i|
      d[i][j] = if s[i-1] == t[j-1]  # adjust index into string
        d[i-1][j-1]       # no operation required
      else
        [ d[i-1][j]+1,    # deletion
        d[i][j-1]+1,    # insertion
        d[i-1][j-1]+1,  # substitution
      ].min
    end
  end
end
d[m][n]
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

  if language=="Ind_Mnk_Zsm"
    answer_filename="answer/Mnk_Zsm.csv"
    input_filename="partition_graph1210/"+language+"/Ind_Mnk_Zsm_new_"
    max=98
  elsif language=="JaToEn_JaToDe"
    input_filename="partition_graph1210/"+language+"/"+language+"_subgraph_"
    answer_filename="answer/EnToDe.csv"
    max=215
  elsif language=="JaToEn_EnToDe"
    max=239
    input_filename="partition_graph1210/"+language+"/"+language+"_subgraph_"
    answer_filename="answer/Ja_De.csv"
  elsif language=="Zh_Uy_Kz"
    max=1180
    input_filename="partition_graph1210/"+language+"/"+language+"_subgraph_"
    # answer_filename="answer/answer_UK_1122.csv"
  end
  answer = Answer.new(answer_filename)
  answer_hash = {}#hash
  CSV.foreach(answer_filename) do |answer_row|
    answer_hash[answer_row[0]]=answer_row[1..-1]
  end

  share_ratio_after_tandardization=Array.new #答えのA-Bペアのどちらかと繋がっているpivotの数
  1.upto(max) do |i|
    transgraph = Transgraph.new(input_filename+"#{i}.csv")
    pivot_connected=Set.new
    pivot_share=Set.new
    raw_output={}
    each_trans_share_ratio_after_tandardization=Array.new #答えのA-Bペアのどちらかと繋がっているpivotの数

    pivot_connected_num=Array.new #答えのA-Bペアのどちらかと繋がっているpivotの数
    pivot_share_num=Array.new #答えのA-Bペアの両方と繋がっているpivotの数
    share_ratio=Array.new #pivotの共有率
    transgraph.node_a.each{|node_a|
      transgraph.node_b.each{|node_b|
        # pp node_b
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
=begin 母集団
      if share_ratio.standard_deviation !=0
        share_ratio.each{|sr|
          # pp (sr-share_ratio.avg)/share_ratio.standard_deviation
          # each_trans_share_ratio_after_tandardization.push((sr-share_ratio.avg)/share_ratio.standard_deviation)
          # share_ratio_after_tandardization.push((sr-share_ratio.avg)/share_ratio.standard_deviation)
        }
      else
        # 標準偏差が0ということはすべてのshare_ratioの値が同じとき
        share_ratio.each{|sr|
          # puts "0"
          # each_trans_share_ratio_after_tandardization.push(0)
          # share_ratio_after_tandardization.push(0)

        }
      end
      # pp each_trans_share_ratio_after_tandardization.avg
      # share_ratio_after_tandardization.push(each_trans_share_ratio_after_tandardization.avg)
# 母集団
=end
# =begin 答え
      if share_ratio.standard_deviation !=0
        share_ratio_answer.each{|sr_answer|
          # pp (sr_answer-share_ratio.avg)/share_ratio.standard_deviation
          each_trans_share_ratio_after_tandardization.push((sr_answer-share_ratio.avg)/share_ratio.standard_deviation)
        }
      else
        # 標準偏差が0ということはすべてのshare_ratioの値が同じとき
        share_ratio_answer.each{|sr_answer|
          # puts "0"
          each_trans_share_ratio_after_tandardization.push(0)
        }
      end
# =end
      # pp each_trans_share_ratio_after_tandardization.avg
      # share_ratio_after_tandardization.push(each_trans_share_ratio_after_tandardization.avg)
    end
=begin debug
    if share_ratio_answer.size>0
      pp "#{i}番目のトランスグラフ"
      pp "生データ"
      pp share_ratio
      pp share_ratio_answer
      puts "トランスグラフ内全ての平均"
      pp share_ratio.avg # puts "トランスグラフ内全ての平均"
      puts "トランスグラフ内全ての分散"
      pp share_ratio.variance # puts "トランスグラフ内全ての分散"
      puts "任意のデータの標本後"
      if share_ratio.standard_deviation !=0
        share_ratio.each{|sr|
          pp (sr-share_ratio.avg)/share_ratio.standard_deviation
        }
      else
        # 標準偏差が0ということはすべてのshare_ratioの値が同じとき
        share_ratio.each{|sr|
          puts "0"
        }
      end
      puts "答えデータのピボット共有率平均"
      pp share_ratio_answer.avg # puts "答えデータのピボット共有率平均"
      puts "答えデータ全ての分散"
      pp share_ratio_answer.variance # puts "答えデータ全ての分散"
      puts "答えデータの標本後"
      if share_ratio.standard_deviation !=0
        share_ratio_answer.each{|sr_answer|
          pp (sr_answer-share_ratio.avg)/share_ratio.standard_deviation
        }
      else
        # 標準偏差が0ということはすべてのshare_ratioの値が同じとき
        share_ratio_answer.each{|sr_answer|
          puts "0"
        }
      end
    end
=end
  end
  # pp "debug"
  # pp share_ratio_after_tandardization
  # pp "標準化後の平均"
  # pp share_ratio_after_tandardization.avg
  # pp "標準化後の分散"
  # pp share_ratio_after_tandardization.variance

end

#入力に答えデータを必要としない
# この関数の中で答えデータ探してる
# マルダンのアプリケーションを通過する答えデータが全然ない。なんで
# きちんと答えデータ作成できればmeasure_share_ratio関数にまとめれるはず

def measure_share_ratio_zuk
  language="Zh_Uy_Kz"
  input_filename="partition_graph1210/"+language+"/"+language+"_subgraph_"
  max=215
  tmp_count=0

  0.upto(max) do |i|
    transgraph = Transgraph.new(input_filename+"#{i}.csv")
    pivot_connected=Set.new
    pivot_share=Set.new
    raw_output={}

    pivot_connected_num=Array.new #答えのA-Bペアのどちらかと繋がっているpivotの数
    pivot_share_num=Array.new #答えのA-Bペアの両方と繋がっているpivotの数
    share_ratio=Array.new #pivotの共有率

    pivot_connected_num_answer=Array.new #答えのA-Bペアのどちらかと繋がっているpivotの数
    pivot_share_num_answer=Array.new #答えのA-Bペアの両方と繋がっているpivotの数
    share_ratio_answer=Array.new #pivotの共有率

    transgraph.lang_a_b.each{|node_a, value_arr|
      value_arr.each{|node_b|
        # transgraph.node_a.each{|node_a|
        #   transgraph.node_b.each{|node_b|
        pivot_connected=transgraph.lang_a_p[node_a] + transgraph.lang_b_p[node_b]#setの和部分
        pivot_connected_num.push(pivot_connected.size)#answer_valueとanswer_keyと接続しているpivot
        pivot_share_num.push(pivot_share.size)
        share_ratio.push(pivot_share_num[-1].fdiv(pivot_connected_num[-1])) #pivotの共有率

        # if levenshtein_distance(node_a,node_b)<2
        if node_a==node_b
          pivot_connected=transgraph.lang_a_p[node_a] + transgraph.lang_b_p[node_b]#setの和部分
          pivot_share=transgraph.lang_a_p[node_a] & transgraph.lang_b_p[node_b]#setの共通部分
          pivot_connected_num_answer.push(pivot_connected.size)#node_bとnode_aと接続しているpivot
          pivot_share_num_answer.push(pivot_share.size)
          share_ratio_answer.push(pivot_share_num_answer[-1].fdiv(pivot_connected_num_answer[-1])) #pivotの共有率
        end
      }
    }
    if share_ratio_answer.size>0
      # pp share_ratio.avg # puts "トランスグラフ内全ての平均"
      # pp share_ratio_answer.avg # puts "答えデータのピボット共有率平均"
      if share_ratio.standard_deviation !=0
        share_ratio_answer.each{|sr_answer|
          pp (sr_answer-share_ratio.avg)/share_ratio.standard_deviation
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

#measure_share_ratioを使えばよさそう
def measure_share_ratio_jaen_jade
  # language="JaToEn_EnToDe"
  language="JaToEn_JaToDe"
  # language="Ind_Mnk_Zsm"
  # input_filename="partition_graph1210/"+language+"/"+language+"_subgraph_"
  input_filename="partition_graph1210/"+language+"/"+language+"_subgraph_"
  # input_filename="partition_graph1210/"+language+"/Ind_Mnk_Zsm_new_"

  # answer_filename="answer/#{$stdin.gets.chomp}.csv"
  # answer_filename="answer/Ja_De.csv"
  # answer_filename="answer/Mnk_Zsm.csv"
  answer_filename="answer/EnToDe.csv"
  # max=239
  max=215
  # max=98
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
        # pp node_b
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
        # pp "#{answer_key} #{answer_value} exists"
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
      # pp share_ratio.avg # puts "トランスグラフ内全ての平均"
      pp share_ratio_answer.avg # puts "答えデータのピボット共有率平均"
      if share_ratio.standard_deviation !=0
        share_ratio_answer.each{|sr_answer|
          # pp (sr_answer-share_ratio.avg)/share_ratio.standard_deviation
        }
      else
        # 標準偏差が0ということはすべてのshare_ratioの値が同じとき
        share_ratio_answer.each{|sr_answer|
          # puts "0"
        }
      end
    end
  end
end

main
