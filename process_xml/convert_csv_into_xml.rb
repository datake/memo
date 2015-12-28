require 'csv'

puts "変換するcsvファイルを拡張子なしで指定(例 joined/en-ja-de)"
input=$stdin.gets.chomp
input_filename=input+".csv"
output_filename=input+".xml"

File.open(output_filename, "w") do |out|
  out.puts "<?xml version='1.0' ?>"
  out.puts "<DocumentElement>"
  CSV.foreach(input_filename) do |row|
    out.puts "<zuk_fixed>"
    out.puts  "<Zh>#{row[0]}</Zh>"
    out.puts  "<Pn>-</Pn>"
    out.puts  "<Ug>#{row[1]}</Ug>"
    out.puts  "<Kz>#{row[2]}</Kz>"
    out.puts  "</zuk_fixed>"
  end
  out.puts "</DocumentElement>"
end
