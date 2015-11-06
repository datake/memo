require 'csv'
require 'pp'
require 'logger'

puts "ファイルで出力される名称を設定(例:Ja_De)"
language=$stdin.gets.chomp
puts "ooファイルの個数"
oofile_num=$stdin.gets.chomp.to_i
#oofile_num=49
input_filename="buffer2/graph_"
answer_filename="answer/"+language+".csv"
output_filename="validation/"+language+"_validation.csv"
error_log_filename="validation/"+language+"_error_log.csv"
#log = Logger.new("validation/"+language+"error.log")
start_from_this_line = 0

File.open(error_log_filename, "w") do |errorlog|
  answer = {}#hash
  CSV.foreach(answer_filename) do |answer_row|#answer_rowはsource1,target1,target2,target3,..
    answer[answer_row[0]]=answer_row[1..-1]
  end

  unregistered_num=0;
  precisions=Array.new#precisionは作成した辞書のうち正しい割合
  recalls=Array.new#recallは現存する辞書でひい単語のうち作成した辞書がカバーできている割合

  #出力結果の検証
  File.open(output_filename, "w") do |io|
    for num in 1 .. oofile_num do
      begin
        CSV.foreach(input_filename + num.to_s + ".oo", :col_sep => "\t") do |rows|
            if answer.has_key?(rows[1])#そのkeyのエントリーが存在する
              if answer[rows[1]].include?(rows[2])
               io.puts(num.to_s+","+rows[1]+"-"+rows[2]+" is included ")
               precisions.push(1)#1/1
               recalls.push(1.fdiv(answer[rows[1]].size))#1/N
              else
               io.puts(num.to_s+","+rows[1]+"-"+rows[2]+" is not included ")
               precisions.push(0)#0/1
               recalls.push(0)#0/N
              end
            else
              io.puts(num.to_s+","+rows[1]+" unregistered")
            end
        end
      rescue => error
        errorlog.puts error.message
        next
      end
    end
  #precisionとreacllをターミナルに表示
  pp precisions.inject(0.0){|r,i| r+=i }/precisions.size #precision平均
  pp recalls.inject(0.0){|r,i| r+=i }/recalls.size #recall平均
  io.puts precisions.inject(0.0){|r,i| r+=i }/precisions.size #precision平均
  io.puts recalls.inject(0.0){|r,i| r+=i }/recalls.size #recall平均
  end
end
