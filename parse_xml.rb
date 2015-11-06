require 'rexml/document'
require 'pp'
def main
  puts "変換するxmlファイルを拡張子なしで指定(例 joined/en-ja-de)"
  input=$stdin.gets.chomp
  input_filename=input+".xml"
  output_filename=input+".csv"

  doc = REXML::Document.new(open(input_filename))
  doc.elements.each('DocumentElement/zuk_fixed') { |element|
    ind = element.elements['Zh'].text
    mnk  = element.elements['Ug'].text
    ms = element.elements['Kz'].text
    ind_arr=ind.split("-")
    mnk_arr=mnk.split("-")
    ms_arr=ms.split("-")
    #pp ind_arr.last #最後の要素を取り出す
  }
end

main
