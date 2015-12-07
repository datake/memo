require 'rexml/document'
require 'pp'

def main
  parse_xml_to_csv
  # parse_Indnesia
  # parse_zuk_answer
end

# => 指定したxmlファイルの答えデータを取得(スペルが同じものを答えとして)
def parse_zuk_answer
  # puts "変換するxmlファイルを拡張子なしで指定(例 joined/Z_U_K)"
  # input=$stdin.gets.chomp
  input="joined/Z_U_K"
  input_filename="#{input}.xml"
  output_filename="{input}_answer.csv"
  filename_zu="{input}_answer_ZU.csv"
  filename_zk="{input}_answer_ZK.csv"
  filename_uk="{input}_answer_UK.csv"

  doc = REXML::Document.new(open(input_filename))
  File.open(output_filename, "w") do |io|
    File.open(filename_zu, "w") do |io_zu|
      File.open(filename_zk, "w") do |io_zk|
        File.open(filename_uk, "w") do |io_uk|
          doc.elements.each('DocumentElement/zuk_fixed') { |element|
            zh = element.elements['Zh'].text
            ug  = element.elements['Ug'].text
            kz = element.elements['Kz'].text
            # CSV出力
            # io.puts("\"#{zh}\",\"#{ug}\",\"#{kz}\"")
            # io_zu.puts("\"#{zh}\",\"#{ug}\"")
            # io_zk.puts("\"#{zh}\",\"#{kz}\"")
            # io_uk.puts("\"#{ug}\",\"#{kz}\"")

            #ugやkzにはcommma区切りで単語が入っている
            #ugとkzの単語で文字列が一致するもののみ出力(答えデータ)
            ug_arr=split_comma_to_array(ug)
            kz_arr=split_comma_to_array(kz)
            if ug_arr.is_a?(Array) && kz_arr.is_a?(Array)
              ug_arr.each{|ug|
                kz_arr.each{|kz|
                  if ug==kz
                    io.puts("\"#{zh}\",\"#{ug}\",\"#{kz}\"")
                    io_zu.puts("\"#{zh}\",\"#{ug}\"")
                    io_zk.puts("\"#{zh}\",\"#{kz}\"")
                    io_uk.puts("\"#{ug}\",\"#{kz}\"")
                  end
                }
              }
            end
          }
        end
      end
    end
  end
end

# => parse_xml_to_csv関数との違いはArbiからもらったIndonesiaは最初に品詞がついていたので品詞を取り除く処理(split_part_of_speech)を行っている
def parse_Indnesia
  puts "変換するxmlファイルを拡張子なしで指定(例 joined/en-ja-de)"
  input=$stdin.gets.chomp
  input_filename=input+".xml"
  output_filename=input+".csv"
  filename_ap=input+"_2.csv"
  filename_bp=input+"_3.csv"

  doc = REXML::Document.new(open(input_filename))
  File.open(output_filename, "w") do |io|
    File.open(filename_ap, "w") do |io_pa|
      File.open(filename_bp, "w") do |io_pb|
        doc.elements.each('DocumentElement/zuk_fixed') { |element|
          ind = element.elements['Zh'].text
          mnk  = element.elements['Ug'].text
          ms = element.elements['Kz'].text

          ind=split_part_of_speech(ind)
          mnk=split_part_of_speech(mnk)
          ms=split_part_of_speech(ms)#msのみ最初の数値-"を除去
          ms=split_part_of_speech(ms)

          io.puts("\"#{ind}\",\"#{mnk}\",\"#{ms}\"")
          io_pa.puts("\"#{ind}\",\"#{mnk}\"")
          io_pb.puts("\"#{ind}\",\"#{ms}\"")
        }
      end
    end
  end
end

def parse_xml_to_csv
  puts "変換するxmlファイルを拡張子なしで指定(例 joined/en-ja-de)"
  input=$stdin.gets.chomp
  input_filename=input+".xml"
  output_filename=input+".csv"
  filename_ap=input+"_pa.csv"
  filename_bp=input+"_pb.csv"

  doc = REXML::Document.new(open(input_filename))
  File.open(output_filename, "w") do |io|
    File.open(filename_ap, "w") do |io_pa|
      File.open(filename_bp, "w") do |io_pb|
        doc.elements.each('DocumentElement/zuk_fixed') { |element|
          ind = element.elements['Zh'].text
          mnk  = element.elements['Ug'].text
          ms = element.elements['Kz'].text
          io.puts("\"#{ind}\",\"#{mnk}\",\"#{ms}\"")
          io_pa.puts("\"#{ind}\",\"#{mnk}\"")
          io_pb.puts("\"#{ind}\",\"#{ms}\"")
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
def split_comma_to_array (text)
  #text=text.gsub(/\s/, ',')
  lang_arr=text.split
  if lang_arr.is_a?(Array)
    return lang_arr
  elsif lang_arr.is_a?(String)
    return [lang_arr]
  else
    return ""
  end
end


main
