require 'csv'
require 'pp'
require 'logger'
require 'set'
require 'unf'

def main
  measure_standardized_share_ratio
  # measure_simple_share_ratio
  # measure_share_ratio_zuk
  # measure_share_ratio_jaen_jade
  # get_zuk_answer_from_each_trans
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
      if row.size==3
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
          @node_a<<a.to_s
        }
        array_of_b.each{|b|
          @node_b<<b.to_s
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
    @answer_head_trans = Hash.new {|h,k| h[k]=[]}
    CSV.foreach(answer_filename) do |row|
      if row.size>=2
        @answer[row[0]]=row[1..-1]
        if row[0 .. -1].size>1
          row[1..-1].each{|trans|
            if answer_head_trans.has_key?(trans)
              answer_head_trans[trans] << row[0]
            #まだ登録されていないkeyならvalueに追加
            else
              answer_head_trans[trans] << row[0]
            end
          }
        end
      end
    end
  end
  attr_accessor :answer
  attr_accessor :answer_head_trans
end


def split_comma_to_array (text)
  # text=text.gsub(/"/, '')
  lang_arr=text.split(",")
  return lang_arr
end


#3言語辞書データと答えの辞書データを入力
#pivotの共有率を返す
def measure_standardized_share_ratio
  # languages = ["JaToEn_JaToDe","JaToEn_EnToDe","JaToDe_DeToEn","Zh_Uy_Kz"]
  languages = ["Ind_Mnk_Zsm"]

  languages.each{|language|
  # language="JaToEn_JaToDe"

  # output=0 -> 標準化後の母集団(任意のペア)のピボット共有率
  # output=1 -> 標準化後の答えのペアのピボット共有率
  # output=2 -> 標準化後の答えペアのピボット共有率のトランスグラフ平均(一つのトランスグラフに複数答えあったらまとめる)
  # output=3 -> いろいろdebug用
  # output=4 -> 標準化前の母集団の平均と分散をだす
  # output=5 -> 標準化前の答えペアの平均と分散をだす

  output=2
  is_population_connected_only=1 #母集団の取り方
  tmp=0
  output_folder="standardized_share_ratio/"

  if language=="Ind_Mnk_Zsm"
    answer_filename="answer/Mnk_Zsm.csv"
    input_filename="partition_graph_1227/"+language+"/"+language+"_subgraph_"
    max=155 #Indのときだけ0からはじめる
  elsif language=="JaToEn_JaToDe"
    input_filename="partition_graph_1227/"+language+"/"+language+"_subgraph_"
    answer_filename="answer/En_De.csv"
    max=389
  elsif language=="JaToEn_EnToDe"
    max=453
    input_filename="partition_graph_1227/"+language+"/"+language+"_subgraph_"
    answer_filename="answer/Ja_De.csv"
  elsif language=="JaToDe_DeToEn"
    max=364
    input_filename="partition_graph_1227/"+language+"/"+language+"_subgraph_"
    answer_filename="answer/Ja_En.csv"
  elsif language=="Zh_Uy_Kz"
    max=1475
    input_filename="partition_graph_1227/"+language+"/"+language+"_subgraph_"
    # answer_filename="answer/Uy_Kz_answer_has_many.csv"
    # answer_filename="answer/Uy_Kz.csv"
    answer_filename="answer/answer_UK_distance1_ruby_each_trans.csv"
  end
=begin
  if language=="Zh_Uy_Kz" #{language=="Ind_Mnk_Zsm" || }
    answer = Answer.new(answer_filename)
    answer_hash = Hash.new {|h,k| h[k]=[]}#hash
    CSV.foreach(answer_filename) do |answer_row|#answer_rowはsource1,target1,target2,target3,..
      if answer_row.size ==2

        #もし既に登録されてるkeyならvalueの末尾に追加する
        if answer_hash.has_key?(answer_row[0])
          answer_hash[answer_row[0]] << answer_row[1]
        #まだ登録されていないkeyならvalueに追加
        else
          answer_hash[answer_row[0]] << answer_row[1]
        end
      end
    end
  else
=end
  answer = Answer.new(answer_filename)

  answer_hash = {}#hash
  CSV.foreach(answer_filename) do |answer_row|
    answer_hash[answer_row[0]]=answer_row[1..-1]
  end

  # pp answer_hash
  # pp answer.answer
  all_trans_sr_standardized=Array.new
  # 1.upto(max) do |i|
  0.upto(max) do |i|
    begin
      # pp "****************#{i}******************"
      transgraph = Transgraph.new(input_filename+"#{i}.csv")
      # pp transgraph.nofde_a
      pivot_connected=Set.new
      pivot_share=Set.new
      raw_output={}
      each_trans_sr_standardized=Array.new

      pivot_connected_num=Array.new #答えのA-Bペアのどちらかと繋がっているpivotの数
      pivot_share_num=Array.new #答えのA-Bペアの両方と繋がっているpivotの数
      share_ratio=Array.new #pivotの共有率

      # 母集団データのピボット共有率の計測
      transgraph.node_a.each{|node_a|
        transgraph.node_b.each{|node_b|
          pivot_connected=transgraph.lang_a_p[node_a] + transgraph.lang_b_p[node_b]#setの和部分
          pivot_share=transgraph.lang_a_p[node_a] & transgraph.lang_b_p[node_b]#setの共通部分
          if is_population_connected_only==1 && pivot_share.size==0
            print("とばす")
          else
            pivot_connected_num.push(pivot_connected.size)#answer_valueとanswer_keyと接続しているpivot
            pivot_share_num.push(pivot_share.size)
            share_ratio.push(pivot_share_num[-1].fdiv(pivot_connected_num[-1])) #pivotの共有率
          end
        }
      }
      pivot_connected_num_answer=Array.new #答えのA-Bペアのどちらかと繋がっているpivotの数
      pivot_share_num_answer=Array.new #答えのA-Bペアの両方と繋がっているpivotの数
      share_ratio_answer=Array.new #pivotの共有率
      has_answer=0
      kvstring=""

      #答えのピボット共有率
      answer.answer.each{|answer_key, answer_values|
        if answer_values
          answer_values.each{|answer_value|#全てのanswerのA-Bについて走査
            if language=="Ind_Mnk_Zsm"
              transgraph.node_a.each{|node_a|
                if answer_key == node_a.split(/\s*(_|-)\s*/)[-1]#Mnkが同じ
                  transgraph.lang_a_b[node_a].each{|node_b|
                    if answer_value == node_b.split(/\s*(_|-)\s*/)[-1]#Zsmが同じ
                      pivot_connected=transgraph.lang_a_p[node_a] + transgraph.lang_b_p[node_b]#setの和部分
                      pivot_share=transgraph.lang_a_p[node_a] & transgraph.lang_b_p[node_b]#setの共通部分
                      pivot_connected_num_answer.push(pivot_connected.size)#node_bとnode_aと接続しているpivot
                      pivot_share_num_answer.push(pivot_share.size)
                      share_ratio_answer.push(pivot_share_num_answer[-1].fdiv(pivot_connected_num_answer[-1])) #pivotの共有率
                    end
                  }
                end
              }
            else
              if transgraph.lang_a_b.has_key?(answer_key)#同じ日本語の見出し語があるか
                if transgraph.lang_a_b[answer_key].include?(answer_value)#同じドイツ語の単語があるか
                  pp "#{answer_key} & #{answer_value} exists"
                  kvstring+="#{answer_key} and #{answer_value} exists"
                  tmp+=1
                  pivot_connected=transgraph.lang_a_p[answer_key] + transgraph.lang_b_p[answer_value]#setの和部分
                  pivot_share=transgraph.lang_a_p[answer_key] & transgraph.lang_b_p[answer_value]#setの共通部分
                  pivot_connected_num_answer.push(pivot_connected.size)#answer_valueとanswer_keyと接続しているpivot
                  pivot_share_num_answer.push(pivot_share.size)
                  # pp pivot_share_num[-1].fdiv(pivot_connected_num_answer[-1])

                  share_ratio_answer.push(pivot_share_num_answer[-1].fdiv(pivot_connected_num_answer[-1])) #pivotの共有率
                # else
                  # pp "#{answer_key} found but #{answer_value} doent exists"
                end
                # pp "#{answer_key} does not found"
              end
            end
          }
        end
      }

      if share_ratio_answer.size>0 #&& has_answer==1
        pp "****************#{i}******************"
        if output == 0 # 標準化後の母集団(任意のペア)のピボット共有率
          File.open(output_folder+"standardized_population_sr_#{language}.csv", "a") do |io| #ファイルあるなら末尾追記
            if share_ratio.standard_deviation !=0
              share_ratio.each{|sr|
                pp (sr-share_ratio.avg)/share_ratio.standard_deviation
                io.puts (sr-share_ratio.avg)/share_ratio.standard_deviation
                # all_trans_sr_standardized.push((sr-share_ratio.avg)/share_ratio.standard_deviation)
              }
            else
              # 標準偏差が0ということはすべてのshare_ratioの値が同じとき
              share_ratio.each{|sr|
                puts "0"
                io.puts 0
                # all_trans_sr_standardized.push(0)
              }
            end
          end
        elsif output == 1 # 標準化後の答えのペアのピボット共有率
          File.open(output_folder+"standardized_answer_sr_#{language}.csv", "a") do |io| #ファイルあるなら末尾追記
            if share_ratio.standard_deviation !=0
              share_ratio_answer.each{|sr_answer|
                pp (sr_answer-share_ratio.avg)/share_ratio.standard_deviation
                io.puts (sr_answer-share_ratio.avg)/share_ratio.standard_deviation
                # each_trans_sr_standardized.push((sr_answer-share_ratio.avg)/share_ratio.standard_deviation)
              }
            else
              # 標準偏差が0ということはすべてのshare_ratioの値が同じとき
              share_ratio_answer.each{|sr_answer|
                puts "0"
                io.puts 0
                # each_trans_sr_standardized.push(0)
              }
            end
          end
        elsif output == 2 # 標準化後の答えペアのピボット共有率のトランスグラフ平均(一つのトランスグラフに複数答えあったらまとめる)
          if share_ratio.standard_deviation !=0
            share_ratio_answer.each{|sr_answer|
              each_trans_sr_standardized.push((sr_answer-share_ratio.avg)/share_ratio.standard_deviation)
            }
          else
            # 標準偏差が0ということはすべてのshare_ratioの値が同じとき
            share_ratio_answer.each{|sr_answer|
              each_trans_sr_standardized.push(0)
            }
          end
          File.open(output_folder+"average_answer_sr_#{language}.csv", "a") do |io| #ファイルあるなら末尾追記
            io.puts i.to_s+","+each_trans_sr_standardized.avg.to_s+","+kvstring
          end
          pp each_trans_sr_standardized.avg
          all_trans_sr_standardized.push(each_trans_sr_standardized.avg)
        elsif output==3
          if share_ratio.standard_deviation !=0
            pp "全体-#{i}"
            share_ratio.each{|sr|
              pp (sr-share_ratio.avg)/share_ratio.standard_deviation
              # all_trans_sr_standardized.push((sr-share_ratio.avg)/share_ratio.standard_deviation)
            }
          else
            # 標準偏差が0ということはすべてのshare_ratioの値が同じとき
            share_ratio.each{|sr|
              puts "0"
              # all_trans_sr_standardized.push(0)
            }
          end
          if share_ratio.standard_deviation !=0
            pp "answer-#{i}"
            share_ratio_answer.each{|sr_answer|
              pp (sr_answer-share_ratio.avg)/share_ratio.standard_deviation
              # each_trans_sr_standardized.push((sr_answer-share_ratio.avg)/share_ratio.standard_deviation)
            }
          else
            # 標準偏差が0ということはすべてのshare_ratioの値が同じとき
            share_ratio_answer.each{|sr_answer|
              puts "0"
              # each_trans_sr_standardized.push(0)
            }
          end
          pp "標準化後答え-#{i}"
          if share_ratio.standard_deviation !=0
            share_ratio_answer.each{|sr_answer|
              each_trans_sr_standardized.push((sr_answer-share_ratio.avg)/share_ratio.standard_deviation)
            }
          else
            # 標準偏差が0ということはすべてのshare_ratioの値が同じとき
            share_ratio_answer.each{|sr_answer|
              each_trans_sr_standardized.push(0)
            }
          end
          pp each_trans_sr_standardized.avg
          all_trans_sr_standardized.push(each_trans_sr_standardized.avg)
        elsif output==4
          File.open("population_average.csv", "a") do |io_average|
            io_average.puts language+","+share_ratio.avg.to_s
            pp "標準化後の平均(一トランスグラフ内)の平均(全てのトランスグラフでの)"
            pp all_trans_sr_standardized.avg
          end
        elsif output==5
          File.open("answer_average.csv", "a") do |io_average|
            io_average.puts language+","+share_ratio_answer.avg.to_s
            pp "標準化後の平均(一トランスグラフ内)の平均(全てのトランスグラフでの)"
            pp all_trans_sr_standardized.avg
          end
        end
      end
    rescue => ex
      puts ex.message
      next
    end
  end
  if output == 2
    File.open(output_folder+"average_of_average_of_sr.csv", "a") do |io_average_of_average|
      pp "標準化後の平均(一トランスグラフ内)の平均(全てのトランスグラフでの)"
      pp all_trans_sr_standardized.avg
      io_average_of_average.puts(language)
      io_average_of_average.puts(all_trans_sr_standardized.avg)
    end
  end

  }
end


#3言語辞書データと答えの辞書データを入力
#pivotの共有率を返す
#トランスグラフのピボット数やノード数気にしてない
def measure_simple_share_ratio
  puts "share_ratio以下のP,A,Bの3言語のcsvファイル(ex.JaToEn_EnToDe,Ind_Mnk_Zsm_new)"
  # inmput_filename="share_ratio/#{$stdin.gets.chomp}.csv"
  # input_filename="share_ratio/JaToEn_EnToDe.csv"
  # input_filename="share_ratio/Ind_Mnk_Zsm_new.csv"
  input_filename="joined/Z_U_K.csv"
  puts "answer以下のA-B答えののcsvファイル(ex.Ja_De,Mnk_Zsm)"
  # answer_filename="answer/#{$stdin.gets.chomp}.csv"
  # answer_filename="answer/Ja_De.csv"
  # answer_filename="answer/Mnk_Zsm.csv"
  # answer_filename="answer/U_K.csv"
  # answer_filename="ZUKdata_1122/answer_UK.csv"
  answer_filename="answer/Uy_Kz_answer_has_many.csv"


  # output_filename="output.csv"
  #TODO:もうひとつ答えもいる?日->独と独->日は別)

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
  answer.answer.each{|answer_key, answer_values|
    pp "key:#{answer_key}"
    pp answer_values
    # answer_valueは配列
    answer_values.each{|answer_value|#全てのanswerのA-Bについて走査
      if transgraph.lang_a_b.has_key?(answer_key)#同じ日本語の見出し語があるか
        if transgraph.lang_a_b[answer_key].include?(answer_value)#同じドイツ語の単語があるか
          # pp "#{answer_key} & #{answer_value} exists"
          #answer_keyとanswer_valueに接続する全てのpivotの集合をとる
          # pp transgraph.lang_a_p[answer_key]
          # pp transgraph.lang_b_p[answer_value]

            pivot_connected=transgraph.lang_a_p[answer_key] + transgraph.lang_b_p[answer_value]#setの和部分

            pivot_share=transgraph.lang_a_p[answer_key] & transgraph.lang_b_p[answer_value]#setの共通部分
          # unless pivot_share.size==1 && pivot_connected.size==1
            pivot_connected_num.push(pivot_connected.size)#answer_valueとanswer_keyと接続しているpivot
            pivot_share_num.push(pivot_share.size)
            # pp pivot_share_num[-1].fdiv(pivot_connected_num[-1])
            if raw_output.has_key?("#{pivot_share_num[-1]}/#{pivot_connected_num[-1]}")
              raw_output["#{pivot_share_num[-1]}/#{pivot_connected_num[-1]}"] = raw_output["#{pivot_share_num[-1]}/#{pivot_connected_num[-1]}"]+1
            else
              raw_output["#{pivot_share_num[-1]}/#{pivot_connected_num[-1]}"] = 1
            end


            share_ratio.push(pivot_share_num[-1].fdiv(pivot_connected_num[-1])) #pivotの共有率
          # end
        else
           pp "#{answer_key} & #{answer_value} doent exists"
        end


      end
    }

  }
  puts share_ratio.inject(0.0){|r,i| r+=i }/share_ratio.size
  pp raw_output.sort {|(k1, v1), (k2, v2)| v2 <=> v1 }
  # pp raw_output
  # pp pivot_connected_num
  # pp pivot_share
  # pp pivot_connected_num
  # pp pivot_share_num
end


main
