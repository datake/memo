require 'csv'
require 'pp'
require 'logger'

def main
  # get_precision_from_2dict
  get_precision_from_1dict
end


# 実際にアルゴリズムを使ってといた結果と二つの答えデータを比較して適合率などを計測する
def get_precision_from_2dict
  language="JaToEn_EnToDe"

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

  output_filename="precision/"+language+"_precision.csv"

  answer = {}#hash
  answer2 = {}#hash
  CSV.foreach(answer_filename) do |answer_row|#answer_rowはsource1,target1,target2,target3,..
    answer[answer_row[0]]=answer_row[1..-1]
  end
  CSV.foreach(answer_filename2) do |answer_row|#answer_rowはsource1,target1,target2,target3,..
    answer2[answer_row[0]]=answer_row[1..-1]
  end

  unregistered_num=0;
  precisions=Array.new#precisionは作成した辞書のうち正しい割合
  # recalls=Array.new#recallは現存する辞書でひい単語のうち作成した辞書がカバーできている割合
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
          if answer.has_key?(rows[1]) && answer2.has_key?(rows[2])#和独辞書で日本語が存在する かつ　独和辞書でドイツ語が存在する
            if answer[rows[1]].include?(rows[2]) #和独辞書でドイツ語があってる
              pp num.to_s+","+rows[1]+","+rows[2]+"日->独で正解"
              is_true_jade=1
            elsif answer2[rows[2]].include?(rows[1])  #独和辞書でドイツ語があってる
              is_true_deja=1
            else
              is_false=1
            end
          else
            is_not_included=1
          end
          if is_true_jade ==1
            io.puts(num.to_s+","+rows[1]+","+rows[2]+",1,0,0,0")
            precisions.push(1)
          elsif is_true_deja ==1
            io.puts(num.to_s+","+rows[1]+","+rows[2]+",0,1,0,0")
            precisions.push(1)
          elsif is_false ==1
            io.puts(num.to_s+","+rows[1]+","+rows[2]+",0,0,1,0")
            precisions.push(0)
          elsif is_not_included ==1
            io.puts(num.to_s+","+rows[1]+","+rows[2]+",0,0,0,1")
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
    answer_filename="answer/Uy_Kz_Marhaba.csv"


  elsif language=="Ind_Mnk_Zsm"
    # oofile_num=192 品詞ありのトランスグラフだと192に分割
    oofile_num=253 #品詞なし
    input_folder="1-1/buffer2_Ind_Mnk_Zsm_253/graph_"
    answer_filename="answer/Mnk_Zsm.csv"
  end

  output_filename="precision/"+language+"_precision.csv"

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

  pp answer
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
          if answer.has_key?(rows[1]) # ウイグル語が答え辞書に登録あり
            if answer[rows[1]].include?(rows[2]) #和独辞書でドイツ語があってる
              is_true=1
            else
              is_false=1
            end
          else # ウイグル語が答え辞書に登録ない
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

=begin
#実際にアルゴリズムを使ってといた結果と答えデータを比較して適合率などを計測する
def get_precision_zuk

  language="Zh_Uy_Kz"

  if language=="Zh_Uy_Kz"
    oofile_num=1183
    # input_filename="partition_graph1210/"+language+"/"+language+"_subgraph_"
    input_folder="1-1/buffer2_zuk_1183/graph_" #総ノード数7以上の場合
    answer_filename="answer/Uy_Kz_1226.csv"
  end

  output_filename="precision/"+language+"_precision.csv"

  answer = {}#hash
  CSV.foreach(answer_filename) do |answer_row|#answer_rowはsource1,target1,target2,target3,..
    answer[answer_row[0]]=answer_row[1..-1]
  end

  unregistered_num=0;
  precisions=Array.new#precisionは作成した辞書のうち正しい割合
  count_trans_flag=0
  #出力結果の検証
  File.open(output_filename, "w") do |io|
    for num in 1 .. oofile_num do
      begin
        CSV.foreach(input_folder + num.to_s + ".oo", :col_sep => "\t") do |rows|
          count_trans_flag=0
          if answer.has_key?(rows[1])#そのkeyのエントリーが存在する
            if answer[rows[1]].include?(rows[2])
              io.puts(num.to_s+","+rows[1]+"-"+rows[2]+" is included ")
              pp num.to_s+","+rows[1]+"-"+rows[2]+" is included "
              precisions.push(1)#1/1

            else
              io.puts(num.to_s+","+rows[1]+"-"+rows[2]+" is not included ")
              pp (num.to_s+","+rows[1]+"-"+rows[2]+" is not included ")
              precisions.push(0)#0/1
            end
          else
            io.puts(num.to_s+","+rows[1]+" unregistered")
          end
        end
      rescue => error
        # errorlog.puts error.message
        pp error.message
        next
      end
    end
    #precisionとreacllをターミナルに表示
    pp precisions.inject(0.0){|r,i| r+=i }/precisions.size #precision平均
    io.puts precisions.inject(0.0){|r,i| r+=i }/precisions.size #precision平均
  end

end
=end
main
