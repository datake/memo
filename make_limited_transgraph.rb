require 'csv'
require 'pp'
require 'logger'
require 'set'
require 'rgl/adjacency'
require 'rgl/dot'

def main

  puts "share_ratio以下のP,A,Bの3言語のcsvファイル(ex.JaToEn_EnToDe,Ind_Mnk_Zsm_new)"
  input_filename="share_ratio/JaToEn_EnToDe.csv"
  transgraph = Transgraph.new(input_filename)

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
    @lang_p_transnum = {}
    @lang_transnum_p = {} #{"transgraph_number"=>Set[pivot1,pivot2,..]}
    transnum=0
    tmp_transmum=0
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
      # @lang_transnum_p = {} #{"transgraph_number"=>Set[pivot1,pivot2,..]}
      @lang_a_p.each{|a, set_of_pivot_a|
        pp a
        set_of_pivot_a.each{|pivot_a|
            pp pivot_a
          if @lang_transnum_p.has_key?(pivot_a)
            tmp_transmum=@lang_p_transnum[pivot_a]
          else
            @lang_p_transnum[pivot_a]=transnum
          end

        }
        transnum+=1

      }
      @lang_b_p.each{|b, set_of_pivot_b|
        pp b
        set_of_pivot_b.each{|pivot_b|
          pp pivot_b
          @lang_p_transnum[pivot_b]=transnum
        }
        transnum+=1
      }

      pp transnum
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

#3言語辞書データと答えの辞書データを入力
#pivotの共有率を返す
def measure_share_ratio_version1
  puts "share_ratio以下のP,A,Bの3言語のcsvファイル(ex.JaToEn_EnToDe,Ind_Mnk_Zsm_new)"
  input_filename="share_ratio/#{$stdin.gets.chomp}.csv"
  # input_filename="share_ratio/JaToEn_EnToDe.csv"
  # input_filename="share_ratio/Ind_Mnk_Zsm_new.csv"
  # input_filename="share_ratio/Z_U_K.csv"
  puts "answer以下のA-B答えののcsvファイル(ex.Ja_De,Mnk_Zsm)"
  answer_filename="answer/#{$stdin.gets.chomp}.csv"
  # answer_filename="answer/Ja_De.csv"
  # answer_filename="answer/Mnk_Zsm.csv"
  # answer_filename="answer/U_K.csv"


  transgraph = Transgraph.new(input_filename) #{"pivot"=>["a", "b"]}
  #pp transgraph.lang_a_p
  answer = Answer.new(answer_filename)

  #答えとなるペアそれぞれについて、以下の3つを出す
  #answer_key_value_pair=Array.new
  pivot_connected=Set.new
  pivot_share=Set.new
  pivot_connected_num=Array.new #答えのA-Bペアのどちらかと繋がっているpivotの数
  pivot_share_num=Array.new #答えのA-Bペアの両方と繋がっているpivotの数
  share_ratio=Array.new #pivotの共有率
  answer.answer.each{|answer_key, answer_values|
    # answer_valueは配列
    answer_values.each{|answer_value|#全てのanswerのA-Bについて走査
      if transgraph.lang_a_b.has_key?(answer_key)#同じ日本語の見出し語があるか
        if transgraph.lang_a_b[answer_key].include?(answer_value)#同じドイツ語の単語があるか
          # pp "#{answer_key} & #{answer_value} exists"
          #answer_keyとanswer_valueに接続する全てのpivotの集合をとる
          # pp transgraph.lang_a_p[answer_key]
          # pp transgraph.lang_b_p[answer_value]
          pivot_connected=transgraph.lang_a_p[answer_key] + transgraph.lang_b_p[answer_value]#setの和部分
          pivot_connected_num.push(pivot_connected.size)#answer_valueとanswer_keyと接続しているpivot
          pivot_share=transgraph.lang_a_p[answer_key] & transgraph.lang_b_p[answer_value]#setの共通部分
          pivot_share_num.push(pivot_share.size)
          # pp pivot_share_num[-1].fdiv(pivot_connected_num[-1])
          p "#{pivot_share_num[-1]}/#{pivot_connected_num[-1]}"
          share_ratio.push(pivot_share_num[-1].fdiv(pivot_connected_num[-1])) #pivotの共有率
        else
          # pp "#{answer_key} & #{answer_value} doent exists"
        end


      end
    }

  }
  puts share_ratio.inject(0.0){|r,i| r+=i }/share_ratio.size
  # pp pivot_connected_num
  # pp pivot_share
  # pp pivot_connected_num
  # pp pivot_share_num
end

#3言語辞書データと答えの辞書データを入力
#pivotの共有率を返す
def measure_share_ratio
  puts "share_ratio以下のP,A,Bの3言語のcsvファイル(ex.JaToEn_EnToDe,Ind_Mnk_Zsm_new)"
  # inmput_filename="share_ratio/#{$stdin.gets.chomp}.csv"
  # input_filename="share_ratio/JaToEn_EnToDe.csv"
  # input_filename="share_ratio/Ind_Mnk_Zsm_new.csv"
  input_filename="share_ratio/Z_U_K.csv"
  puts "answer以下のA-B答えののcsvファイル(ex.Ja_De,Mnk_Zsm)"
  # answer_filename="answer/#{$stdin.gets.chomp}.csv"
  # answer_filename="answer/Ja_De.csv"
  # answer_filename="answer/Mnk_Zsm.csv"
  # answer_filename="answer/U_K.csv"
  answer_filename="answer_UK.csv"

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
  pp in1.size
  pp in2.size
  pp common_key1
  pp common_key2
  pp in1_only_key
  pp in2_only_key

end

main
