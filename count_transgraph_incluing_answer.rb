require 'csv'
require 'pp'
require 'logger'
# トランスグラフごとの複数のCSVを入力として、
# 正解ペアが入っているトランスグラフの数を求めるプログラム

# oofile_num=168
oofile_num=49
input_filename="connected_components1208/each_trans_Ind_Mnk_Zsm/Ind_Mnk_Zsm_new_"
answer_filename="answer/Mnk_Zsm.csv"
start_from_this_line = 0

def split_comma_to_array (text)
  # text=text.gsub(/"/, '')
  lang_arr=text.split(",")
  return lang_arr
end

answer = {}#hash
CSV.foreach(answer_filename) do |answer_row|
  answer[answer_row[0]]=answer_row[1..-1]
end

unregistered_num=0;
count_trans_include_answer=0
count_trans_flag=0
#出力結果の検証
for num in 0 .. oofile_num do
  count_trans_flag=0
  CSV.foreach(input_filename + num.to_s + ".csv") do |rows|
    pp input_filename + num.to_s + ".csv"

    ja_array=[]
    ja_array=split_comma_to_array(rows[1])
    ja_array.each{|ja|
      if answer.has_key?(ja)#そのkeyのエントリーが存在する
        de_array=[]
        de_array=split_comma_to_array(rows[2])
        de_array.each{|de|
          if answer[ja].include?(de)
            puts(num.to_s+","+ja+"-"+de+" is included ")
            if count_trans_flag == 0
              count_trans_include_answer+=1
              count_trans_flag=1
            end
          else
            puts(num.to_s+","+ja+"-"+de+" is not included ")
          end
        }

      else
        puts(num.to_s+","+ja+" unregistered")
      end
    }
    pp "正解ペアが入っているトランスグラフの数"
    pp count_trans_include_answer
  end
end
