require 'csv'
require 'pp'
require 'logger'

=begin
入力->1to1なCSVファイルを読み込み
出力->1toManyにしてCSVファイル出力
=end

puts "入力ファイルを指定(ex Ind_Zsm)"
language=$stdin.gets.chomp
input_filename="input/#{language}_1to1.csv"
output_filename="output/#{language}_1toMany.csv"
# read:
p "reading csv.."
ar=[]
CSV.foreach(input_filename) do |rows|
  ar.push([rows[0],rows[1]])
end

#very very slow.why?
#ar = CSV.table(input_filename).to_a

# manipulate:
p "manipulating"
one_to_many = {}#hash,valueはarray
ar[1..-1].each{|row|
  if one_to_many.has_key?(row[0])#そのkeyが存在する
    if one_to_many[row[0]].include?(row[1])#入力辞書に重複あり
     pp "入力辞書に重複あり"
     pp row
    else
      one_to_many[row[0]].push(row[1])
    end
  else
    one_to_many[row[0]]=[row[1]]
  end
}

one_to_many_ar = one_to_many.to_a#hash->array
# write:
CSV.open(output_filename, 'w') do |csv|
  one_to_many_ar.each{|line|
    line.flatten!
     csv << line
   }
end
