require 'rexml/document'
require 'pp'
def main
  puts "変換するxmlファイルを拡張子なしで指定(例 joined/en-ja-de)"
  input=$stdin.gets.chomp
  input_filename=input+".xml"
  output_filename=input+".csv"
  output_filename_ap=input+"2.csv"
  output_filename_bp=input+"3.csv"

  doc = REXML::Document.new(open(input_filename))
  File.open(output_filename, "w") do |io|
    File.open(filename_ap, "w") do |io_ap|
      File.open(filename_bp, "w") do |io_bp|
        doc.elements.each('DocumentElement/zuk_fixed') { |element|
          ind = element.elements['Zh'].text
          mnk  = element.elements['Ug'].text
          p ms = element.elements['Kz'].text

          #msのみ最初のわけわからん"数値-"を取り除く必要がある
          ms_arr=ms.split(",")
          ms_processed=[]
          ms_arr.each{|ms|
            ms_arr=ms.split("-")
            ms_arr.shift
            ms_processed.push(ms_arr.join("-"))
          }

          ms = ms_processed.join(",")#array to string
          io.puts("\"#{ind}\",\"#{mnk}\",\"#{ms}\"")
          io_ap.puts("\"#{mnk}\",\"#{ind}\"")
          io_bp.puts("\"#{ms}\",\"#{ind}\"")
        }
      end
    end
  end
end

main
