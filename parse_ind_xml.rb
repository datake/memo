require 'rexml/document'
require 'pp'
def main
  puts "変換するxmlファイルを拡張子なしで指定(例 joined/en-ja-de)"
  input=$stdin.gets.chomp
  input_filename=input+".xml"
  output_filename=input+".csv"
  filename_ap=input+"_2.csv"
  filename_bp=input+"_3.csv"

  doc = REXML::Document.new(open(input_filename))
  File.open(output_filename, "w") do |io|
    File.open(filename_ap, "w") do |io_ap|
      File.open(filename_bp, "w") do |io_bp|
        doc.elements.each('DocumentElement/zuk_fixed') { |element|
          ind = element.elements['Zh'].text
          mnk  = element.elements['Ug'].text
          ms = element.elements['Kz'].text

          ind=split_part_of_speech(ind)
          mnk=split_part_of_speech(mnk)
          ms=split_part_of_speech(ms)#msのみ最初の数値-"を除去
          ms=split_part_of_speech(ms)
=begin
          ms_arr=ms.split(",")
          ms_processed=[]
          #msのみ最初の数値-"を取り除く
          ms_arr.each{|ms|
            ms_arr=ms.split("-")
            ms_arr.shift
            ms_processed.push(ms_arr.join("-"))
          }

          ms = ms_processed.join(",")#array to string
=end
          io.puts("\"#{ind}\",\"#{mnk}\",\"#{ms}\"")
          io_ap.puts("\"#{ind}\",\"#{mnk}\"")
          io_bp.puts("\"#{ind}\",\"#{ms}\"")
        }
      end
    end
  end
end

def split_part_of_speech (text)
  lang_arr=text.split(",")
  lang_processed=[]
  #hoge-"を取り除く
  lang_arr.each{|lang|
    lang_arr=lang.split("-")
    lang_arr.shift
    lang_processed.push(lang_arr.join("-"))
  }
  lang = lang_processed.join(",")#array to string
  return lang
end

main
