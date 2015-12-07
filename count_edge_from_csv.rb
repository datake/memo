require 'csv'
require 'pp'
require 'logger'

=begin
入力->1toManyなCSVファイルを読み込み
出力->①枝の数合計②枝の本数ごとのカウント
=end

puts "入力ファイルを相対位置で指定(ex Ind_Zsm)"
language=$stdin.gets.chomp
input_filename="#{language}.csv"
puts "\"\"で囲っているcsvなら1を入力、else 0"
opt=$stdin.gets.chomp.to_i

p "reading csv.."
rows=[]
CSV.foreach(input_filename) do |row|
  rows.push(row)
end

p "manipulating"

edges=[] #ある単語に対して、対訳の単語数(=エッジ数)を単語ごとに入れていく
edges_to_count={} #{"枝数"=>その単語数}

rows[0..-1].each{|row|
  row_target=[]
  if opt > 0 # "source","target1,target2,target3,.."
    row_target=row[1].split(",")
  else # source,target1,target2,target3,..
    row_target=row[1..-1] #先頭要素(見出し語)を削除
  end

  if edges_to_count.has_key?(row_target.size())
    edges_to_count[row_target.size()] = edges_to_count[row_target.size()] + 1
  else
    edges_to_count[row_target.size()] = 1
  end
  edges.push(row_target.size())
}

p "入力CSV総行数"
p rows.size
p "平均エッジ数"
# pp edges
p edges.inject(0.0){|r,i| r+=i }/edges.size
p "エッジ総数"
p edges.inject(0.0){|r,i| r+=i }
p "エッジ累計"
pp edges_to_count.sort
