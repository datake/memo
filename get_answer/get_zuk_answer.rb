require 'csv'
require 'pp'
require 'logger'
require 'set'
require 'unf'

def main
  get_zuk_answer
  # measure_share_ratio
  # measure_share_ratio_ind
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
        #ZUKのデータはカンマ区切りではなく空白区切りで入ってる
        # row[1] = row[1].gsub(/؛/, ',')
        # #
        # row[2] = row[2].gsub(/؛/, '\,')
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
        array_of_a.each{|a|
          @node_a<<a
        }
        array_of_b.each{|b|
          @node_b<<b
        }
      else
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

# ZUKの答えデータを取得する
# 入力ファイルがコンマ区切りか注意すること
# 編集距離0のもの、1のもの、2のもの
# その単語ペアがマルダンのアプリケーションをpassするかは考慮していない
def get_zuk_answer
  # input_filename="share_ratio/Z_U_K.csv"
  answer_filename0="answer/answer_UK_distance0_bigtrans.csv"
  answer_filename1="answer/answer_UK_distance1_bigtrans.csv"
  answer_filename2="answer/answer_UK_distance2_bigtrans.csv"

  transgraph = Transgraph.new(input_filename)
  answer_UK_0={}
  answer_UK_1={}
  answer_UK_2={}
  transgraph.lang_a_b.each{|key, value_arr|
    key=UNF::Normalizer.normalize(key, :nfkc)
    value_arr.each{|value|
      value=UNF::Normalizer.normalize(value, :nfkc)
      lev_distance=levenshtein_distance(key,value)
      if lev_distance==0
        unless answer_UK_0.include?(key)
          answer_UK_0[key]=value
        end
      elsif lev_distance==1 && key[0]==value[0]
        unless answer_UK_1.include?(key)
          answer_UK_1[key]=value
        end
      elsif lev_distance==2 && key[0]==value[0]
        unless answer_UK_2.include?(key)
          answer_UK_2[key]=value
        end
      end
    }
  }
  File.open(answer_filename0, "w") do |out|
    answer_UK_0.each{|key, value|
      out.puts "#{key},#{value}"
    }
  end
  File.open(answer_filename1, "w") do |out|
    answer_UK_1.each{|key, value|
      out.puts "#{key},#{value}"
    }
  end
  File.open(answer_filename2, "w") do |out|
    answer_UK_2.each{|key, value|
      out.puts "#{key},#{value}"
    }
  end
end


main
