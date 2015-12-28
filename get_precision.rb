require 'csv'
require 'pp'
require 'logger'

def main
  get_precision_from_2dict
  # get_precision_from_1dict
  # get_precision_from_zukind
end

class Answer
  def initialize(answer_filename)
    @answer = {}
    # @answer_head_trans = {}
    @answer_head_trans = Hash.new {|h,k| h[k]=[]}
    CSV.foreach(answer_filename) do |row|
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
  attr_accessor :answer
  attr_accessor :answer_head_trans
end


# 実際にアルゴリズムを使ってといた結果と二つの答えデータを比較して適合率などを計測する
def get_precision_from_2dict
  language="JaToDe_DeToEn"

  if language=="JaToEn_EnToDe"
    oofile_num=456
    input_folder="1-1/buffer2_JaEn_EnDe_456/graph_"
    answer_filename="answer/Ja_De.csv"
    answer_filename2="answer/De_Ja.csv"
  elsif language=="JaToEn_JaToDe"
    oofile_num=404
    input_folder="1-1/buffer2_JaEn_JaDe_404/graph_"
    answer_filename="answer/En_De.csv"
    answer_filename2="answer/De_En.csv"
  elsif language=="JaToDe_DeToEn"
    oofile_num=380
    input_folder="1-1/buffer2_JaDe_DeEn_380/graph_"
    answer_filename="answer/Ja_En.csv"
    answer_filename2="answer/En_Ja.csv"
  end

  output_filename="precision/2230"+language+"_testboth_precision.csv"

  answer = {}#hash
  answer2 = {}#hash

  answer = Answer.new(answer_filename)
  answer2 = Answer.new(answer_filename2)

  unregistered_num=0;
  precisions=Array.new#precisionは作成した辞書のうち正しい割合
  count_trans_include_answer=0
  #出力結果の検証
  File.open(output_filename, "w") do |io|
    for num in 1 .. oofile_num do
      begin
        CSV.foreach(input_folder + num.to_s + ".oo", :col_sep => "\t") do |rows|
          is_true_jade=0
          is_true_deja=0
          is_false=0
          is_not_included=0
          #rows[1] -> 日本語
          #rows[2] -> ドイツ語
          # 和独辞書について
          if answer.answer.has_key?(rows[1]) &&  answer.answer_head_trans.has_key?(rows[2])
            if answer.answer[rows[1]].include?(rows[2])
              is_true_jade=1
            elsif answer.answer_head_trans[rows[2]].include?(rows[1])
              is_true_jade=1
            else
              is_false=1
            end
          end

          # 和独辞書について
          if answer2.answer.has_key?(rows[2]) &&  answer2.answer_head_trans.has_key?(rows[1])
            if answer2.answer[rows[2]].include?(rows[1])
              is_true_deja=1
            elsif answer2.answer_head_trans[rows[1]].include?(rows[2])
              is_true_deja=1
            else
              is_false=1
            end
          end
          # 独和辞書について
          if is_true_jade ==1 && is_true_deja ==1
            io.puts(num.to_s+","+rows[1]+","+rows[2]+",0,0,0,0,1")
            precisions.push(1)
          elsif is_true_jade ==1
            io.puts(num.to_s+","+rows[1]+","+rows[2]+",1,0,0,0,0")
            precisions.push(1)
          elsif is_true_deja ==1
            io.puts(num.to_s+","+rows[1]+","+rows[2]+",0,1,0,0,0")
            precisions.push(1)
          elsif is_false ==1
            io.puts(num.to_s+","+rows[1]+","+rows[2]+",0,0,1,0,0")
            precisions.push(0)
          else #正解不正解を判別できない場合
            io.puts(num.to_s+","+rows[1]+","+rows[2]+",0,0,0,1,0")
          end
        end
      rescue => error
        pp error.message
        next
      end
    end
    #precision表示
    pp precisions.inject(0.0){|r,i| r+=i }/precisions.size #precision平均
    io.puts precisions.inject(0.0){|r,i| r+=i }/precisions.size #precision平均
  end
end

#実際にアルゴリズムを使ってといた結果と1つのの答えデータを比較して適合率などを計測する
#答えの辞書データのkeyがuniqueではない
def get_precision_from_1dict

  language="Ind_Mnk_Zsm"

  if language=="Zh_Uy_Kz"
    oofile_num=1480
    # input_filename="partition_graph1210/"+language+"/"+language+"_subgraph_"
    input_folder="1-1/buffer2_zuk_1480/graph_"
    answer_filename="precision/answerZh_Uy_Kz.csv"


  elsif language=="Ind_Mnk_Zsm"
    # oofile_num=192 品詞ありのトランスグラフだと192に分割
    oofile_num=253 #品詞なし
    input_folder="1-1/buffer2_Ind_Mnk_Zsm_253/graph_"
    # answer_filename="answer/Mnk_Zsm.csv"
    answer_filename="precision/answerInd_Mnk_Zsm.csv"
  elsif language=="JaToEn_EnToDe"
    oofile_num=456
    input_folder="1-1/buffer2_JaEn_EnDe_456/graph_"
    answer_filename="answer/Ja_De.csv"
    # answer_filename2="answer/De_Ja.csv"
  elsif language=="JaToEn_JaToDe"
    oofile_num=404
    input_folder="1-1/buffer2_JaEn_JaDe_404/graph_"
    answer_filename="answer/En_De.csv"
    # answer_filename2="answer/De_En.csv"
  elsif language=="JaToDe_DeToEn"
    oofile_num=380
    input_folder="1-1/buffer2_JaDe_DeEn_380/graph_"
    answer_filename="answer/Ja_En.csv"
    # answer_filename2="answer/En_Ja.csv"

  end

  output_filename="precision/2130"+language+"_from1dict__precision.csv"

  answer = Answer.new(answer_filename)
  # pp answer
  unregistered_num=0;
  precisions=Array.new#precisionは作成した辞書のうち正しい割合
  #出力結果の検証
  File.open(output_filename, "w") do |io|
    for num in 1 .. oofile_num do
      begin
        CSV.foreach(input_folder + num.to_s + ".oo", :col_sep => "\t") do |rows|
          pp rows
          is_true=0
          is_false=0
          is_not_included=0
          #rows[1] -> 日本語
          #rows[2] -> ドイツ語
          if answer.answer.has_key?(rows[1]) &&  answer.answer_head_trans.has_key?(rows[2])
            if answer.answer[rows[1]].include?(rows[2])
              is_true=1
            elsif answer.answer_head_trans[rows[2]].include?(rows[1])
              is_true=1
            else
              is_false=1
            end
          else
            is_not_included=1
          end
          if is_true ==1
            io.puts(num.to_s+","+rows[1]+","+rows[2]+",1,0,0")
            precisions.push(1)
          elsif is_false ==1
            io.puts(num.to_s+","+rows[1]+","+rows[2]+",0,1,0")
            precisions.push(0)
          elsif is_not_included ==1
            io.puts(num.to_s+","+rows[1]+","+rows[2]+",0,0,1")
          end
        end
      rescue => error
        pp error.message
        next
      end
    end
    #precision表示
    pp precisions.inject(0.0){|r,i| r+=i }/precisions.size #precision平均
    io.puts precisions.inject(0.0){|r,i| r+=i }/precisions.size #precision平均
  end
end

# zukとindを他の辞書の答えデータと同じ形式にする
def get_answer_from_zukind

  language="Ind_Mnk_Zsm"

  if language=="Zh_Uy_Kz"
    oofile_num=1480
    # input_filename="partition_graph1210/"+language+"/"+language+"_subgraph_"
    input_folder="1-1/buffer2_zuk_1480/graph_"
    answer_filename="answer/Uy_Kz_Marhaba.csv"


  elsif language=="Ind_Mnk_Zsm"
    # oofile_num=192 品詞ありのトランスグラフだと192に分割
    oofile_num=253 #品詞なし
    input_folder="1-1/buffer2_Ind_Mnk_Zsm_253/graph_"
    answer_filename="answer/Mnk_Zsm.csv"

  end

  output_filename="precision/answer"+language+".csv"

  if  language=="Ind_Mnk_Zsm" || language=="Zh_Uy_Kz"
    answer = Hash.new {|h,k| h[k]=[]}#hash
    CSV.foreach(answer_filename) do |answer_row|#answer_rowはsource1,target1,target2,target3,..
      if answer_row.size ==2
        #もし既に登録されてるkeyならvalueの末尾に追加する
        if answer.has_key?(answer_row[0])
          answer[answer_row[0]] << answer_row[1]
        #まだ登録されていないkeyならvalueに追加
        else
          answer[answer_row[0]] << answer_row[1]
        end
      end
    end
  else
    answer = Answer.new(answer_filename)
  end

  # pp answer
  unregistered_num=0;
  precisions=Array.new#precisionは作成した辞書のうち正しい割合
  #出力結果の検証
  File.open(output_filename, "w") do |io|
    answer.each{|key, val|
      if key
        io.print key+","
        val.each_with_index{|v,i|
          if v
            if i +1 == val.size
              io.print v + "\n"
            else
              io.print v +","
            end
          end
        }
      end
    }
  end
end

main
