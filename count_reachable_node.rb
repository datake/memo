require 'csv'
require 'pp'
require 'logger'
require 'set'
require 'unf'

def main
  count_reachable_node

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
class Result
  def initialize(result_filename)
    @result = {}
    @result_head_trans = Hash.new {|h,k| h[k]=[]}
    @is_true=Hash.new { |h,k| h[k] = {} } #二重ハッシュ
    CSV.foreach(result_filename) do |row|
      if row.size>=2
        @result[row[0]]=row[1]
        @result_head_trans[row[1]]=row[0]
        @is_true[row[0]][row[1]]=[row[2]]
      end
    end
  end
  attr_accessor :result
  attr_accessor :result_head_trans
  attr_accessor :is_true

end


def split_comma_to_array (text)
  # text=text.gsub(/"/, '')
  lang_arr=text.split(",")
  return lang_arr
end



def count_reachable_node
  languages = ["JaToEn_EnToDe","JaToDe_DeToEn","JaToEn_JaToDe","Ind_Mnk_Zsm2","Zh_Uy_Kz"]

  t = Time.now
  strTime = t.strftime("%B-%d-%H-%M-%S")
  File.open("reachable/reachable_all_#{strTime}.csv", "w") do |io_all_trans|

    languages.each{|language|
      File.open("reachable/#{language}_all_#{strTime}.csv", "w") do |io_all_lang|
        # answer_types.each{|answer_type|
        is_population_connected_only=1 #母集団の取り方
        # pivot_connected_fixed=2 #ピボット共有率を計測する際の分母(繋がっているノード数)を指定
        output_folder="reachable/"

        input_filename="partition/#{language}/"
        min=1
        if language=="Ind_Mnk_Zsm"
          answer_filename="answer/Mnk_Zsm.csv"
          input_filename="partition_graph_1227/"+language+"/"+language+"_subgraph_"
          max=155 #Indのときだけ0からはじめる
          min=0
        elsif language=="Ind_Mnk_Zsm2" #品詞なしの場合
          input_filename="partition_graph_1227/Ind_Mnk_Zsm_hinsinashi0104/Ind_Mnk_Zsm_subgraph_"
          answer_filename="answer/Mnk_Zsm.csv"
          one_to_one_filename="Ind_Mnk_Zsm"
          max=252
        elsif language=="JaToEn_JaToDe"
          input_filename="partition_graph_1227/"+language+"/"+language+"_subgraph_"
          answer_filename="answer/En_De.csv"
          one_to_one_filename="JaToEn_JaToDe"
          max=389
        elsif language=="JaToEn_EnToDe"
          max=453
          input_filename="partition_graph_1227/"+language+"/"+language+"_subgraph_"
          answer_filename="answer/Ja_De.csv"
          one_to_one_filename="JaToEn_EnToDe"
        elsif language=="JaToDe_DeToEn"
          max=364
          input_filename="partition_graph_1227/"+language+"/"+language+"_subgraph_"
          answer_filename="answer/Ja_En.csv"
          one_to_one_filename="JaToDe_DeToEn"

        elsif language=="Zh_Uy_Kz"
          max=1475
          input_filename="partition_graph_1227/"+language+"/"+language+"_subgraph_"
          # answer_filename="answer/Uy_Kz_answer_has_many.csv"
          # answer_filename="answer/Uy_Kz.csv"
          answer_filename="answer/Marhaba_and_1distance.csv"
          one_to_one_filename="Zh_Uy_Kz"
        elsif language =="EngToDeu_EngToNld"
          max=241
          input_filename="partition_graph_1227/#{language}/#{language}_subgraph_"
          answer_filename="answer/deu_nld_answer.csv"
          one_to_one_filename="EngToDeu_EngToNld"
        end

        all_reachable_node_num_arr=Array.new #pivotの共有率
        min.upto(max) do |transgraph_itr|
          transgraph = Transgraph.new(input_filename+"#{transgraph_itr}.csv")
          reachable_node_num_arr=Array.new #pivotの共有率



          # 母集団データのピボット共有率の計測
          transgraph.node_a.each{|node_a|
            reachable_node_num=0
            is_already_reachable={}
            transgraph.lang_a_p[node_a].each{|reachable_pivot|
              transgraph.lang_p_b[reachable_pivot].each{|reachable_target|
                if is_already_reachable.has_key?(reachable_target) && is_already_reachable[reachable_target]==1
                  # pp "reachableすでに登録済み"
                else
                  reachable_node_num+=1
                  is_already_reachable[reachable_target]=1
                end
              }
            }
            reachable_node_num_arr.push(reachable_node_num)
          }

          all_reachable_node_num_arr.push(reachable_node_num_arr.avg)
          io_all_lang.puts "#{language},#{reachable_node_num_arr.avg}"


        end #一言語での全てのトランスグラフ
        io_all_trans.puts "#{language},#{all_reachable_node_num_arr.avg}"
        # }
      end
    }

  end
end
#



main
