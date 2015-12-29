require 'rgl/base'
require 'rgl/adjacency'
require 'rgl/connected_components'
require 'csv'
require 'pp'
require 'logger'
require 'set'
require 'rgl/dot'

# lang_A="Ja_"
# lang_B="De_"
# lang_P="En_"
def main
  # measure_share_ratio_from_each_trans
  # measure_share_ratio
  make_dot_img_from_each_trans
  # measure_share_ratio_of_transgraph
end

class Transgraph
  def initialize(input_filename)
    @pivot = {}
    @lang_a_b = {}
    @lang_b_a = {}
    @lang_a_p = {}
    @lang_b_p = {}
    @lang_p_a = {}
    @lang_p_b = {}
    CSV.foreach(input_filename) do |row|
      # #ZUKのデータはカンマ区切りではなく空白区切りで入ってる
      # row[1] = row[1].gsub(/؛/, ',')
      # #
      # row[2] = row[2].gsub(/؛/, '\,')
      # pp row[1]
      array_of_a = split_comma_to_array(row[1])
      array_of_b  = split_comma_to_array(row[2])
      @pivot[row[0]]=[array_of_a,array_of_b] #{"pivot"=>[[a1,a2,a3,..], [b1,b2,b3,..]]}

      @lang_p_a[row[0]] = array_of_a
      @lang_p_b[row[0]] = array_of_b
      array_of_a.each{|a|
        array_of_b.each{|b|
          @lang_a_b[a]=array_of_b #{"a1"=>[b1,b2,b3,..]}とか{"a2"=>[b1,b2,b3,..]}
          @lang_b_a[b]=array_of_a #{"b1"=>"a1,a2,a3,..]"}
          #aやbからみたとき、複数のpivotが対応することがある
          if @lang_a_p.has_key?(a)
            @lang_a_p[a] << row[0] #{"a1"=>Set[pivot1,pivot2,..]}
            # pp @lang_a_p[a]
          else
            @lang_a_p[a]=Set[row[0]] #{"a1"=>Set[pivot]}
          end

          if @lang_b_p.has_key?(b)
            @lang_b_p[b] << row[0] #{"b1"=>Set[pivot1,pivot2,..]}
            # pp @lang_b_p[b]
          else
            @lang_b_p[b]=Set[row[0]] #{"b1"=>"Set[pivot]}
            # pp @lang_b_p[b][0]

          end
        }
      }
    end
  end
  attr_accessor :pivot
  attr_accessor :lang_a_b
  attr_accessor :lang_b_a
  attr_accessor :lang_a_p
  attr_accessor :lang_b_p
  attr_accessor :lang_p_a
  attr_accessor :lang_p_b

  def dispName()
    # print(@name, "¥n")
  end
end

class Answer
  def initialize(answer_filename)
    @answer = {} #{"k1"=>["v1", "v2"]}
    CSV.foreach(answer_filename) do |row|
      #{"answer"=>["a", "b"]}
      # pp row
      @answer[row[0]]=row[1..-1]
    end
  end
  attr_accessor :answer
end

def split_comma_to_array (text)
  # text=text.gsub(/"/, '')
  lang_arr=text.split(",")
  return lang_arr
end


def make_dot_img_from_each_trans
  language="Zh_Uy_Kz"
  # language="Ind_Mnk_Zsm_new"
  # language="Zh_Uy_Kz"
  # input_filename="share_ratio/#{language}.csv"
  # input_filename="connected_components/each_trans_#{language}/#{language}"
  # answer_filename="answer/answer_UK_1122.csv"
  output_filename="visualize_1216/csc/#{language}.csv"
  output_each_trans_filename="visualize_1216/#{language}/"

  if language=="Ind_Mnk_Zsm"
    answer_filename="answer/Mnk_Zsm.csv"
    input_filename="partition_graph1210/"+language+"/Ind_Mnk_Zsm_new_"
    max=98
    lang_A="Mnk_"
    lang_B="Zsm_"
    lang_P="Ind_"
  elsif language=="JaToEn_JaToDe"
    input_filename="partition_graph1210/"+language+"/"+language+"_subgraph_"
    answer_filename="answer/EnToDe.csv"
    max=215
  elsif language=="JaToEn_EnToDe"
    max=239
    input_filename="partition_graph1210/"+language+"/"+language+"_subgraph_"
    answer_filename="answer/Ja_De.csv"
    lang_A="Ja_"
    lang_B="De_"
    lang_P="En_"
  elsif language=="Zh_Uy_Kz"
    max=1180
    # input_filename="partition_graph1210/"+language+"/"+language+"_subgraph_"
    input_filename="connected_components/each_trans_#{language}/#{language}_subgraph_"
    answer_filename="answer/answer_UK_1122.csv"
    # answer_filename="answer/answer_UK_distance2_1215.csv"
  end
  # input_filename="connected_components/each_trans_#{language}/#{language}"



  # transgraph = Transgraph.new(input_filename)
  answer = Answer.new(answer_filename)

  #transgraph情報を画像表示
  i_filecount=0

  for i_filecount in 1 .. max

    # transgraph = Transgraph.new("#{input_filename}_subgraph_#{i_filecount}.csv")
    transgraph = Transgraph.new(input_filename+"#{i_filecount}.csv")

    # 空の有向グラフを作る
    g  = RGL::DirectedAdjacencyGraph.new

    transgraph_count=0

    transgraph.pivot.each{|piv|
      tmp_p=piv[0]
      g.add_vertex(tmp_p)

      piv[1][0].each{|tmp_a|
        g.add_vertex("Ja-#{tmp_a}")
        g.add_edge("En-#{tmp_p}","Ja-#{tmp_a}")
      }
      piv[1][1].each{|tmp_b|
        g.add_vertex("De-#{tmp_b}")
        g.add_edge("En-#{tmp_p}","De-#{tmp_b}")
      }
      transgraph_count+=1
    }

    passed_transgraphs = []

    # 「トランスグラフのpivotが2以上、ノードが7以上」という条件を満たしたトランスグラフをpassed_transgraphsという配列にいれる
    # each_connected_componentが接続するサブグラフを返す
    g.to_undirected.each_connected_component { |connected_component|
      count_pivot=0
      if connected_component.size> 6
        connected_component.each{|c|
          if c.start_with?("En-")
            count_pivot+=1
          end
        }
        # マルダンのアプリケーションでパスするトランスグラフ
        if count_pivot>1
          passed_transgraphs <<  connected_component
        end
      end

    }

    # i_filecount=0
    i=0
    output_transgraph=[]
    passed_transgraphs.each{|passed_transgraph|
      pp passed_transgraph
      File.open("#{output_each_trans_filename}#{i_filecount}.dot", "w") do |io|
        File.open("#{output_each_trans_filename}#{i_filecount}.csv", "w") do |io2|
          io.puts "digraph #{i} {"
          io.puts "graph [rankdir = LR];"
          passed_transgraph.each{|node|
            if node.start_with?("En-")
              tmp_pivot=node[3 .. -1]
              output_transgraph[i]  = RGL::DirectedAdjacencyGraph.new
              pp tmp_pivot
              io2.print "\"#{tmp_pivot}\",\""
              # 英->日
              transgraph.lang_p_a[tmp_pivot].each_with_index{|tmp_ja,index|
                if tmp_ja.size == 0
                  next
                end
                output_transgraph[i].add_vertex(tmp_ja)
                output_transgraph[i].add_edge(tmp_pivot,tmp_ja)
                # io.puts "tmp \[\"#{lang_P}#{tmp_pivot}\[color=yellow\]\";"
                io.puts "\"#{lang_A}#{tmp_ja}\"->\"#{lang_P}#{tmp_pivot}\";"
                if index==transgraph.lang_p_a[tmp_pivot].size-1
                  io2.print "#{lang_A}#{tmp_ja}\",\""
                else
                  io2.print "#{lang_A}#{tmp_ja},"
                end
              }

              # 英->独
              transgraph.lang_p_b[tmp_pivot].each_with_index{|tmp_de,index|
                if tmp_de.size == 0
                  next
                end
                output_transgraph[i].add_vertex(tmp_de)
                output_transgraph[i].add_edge(tmp_pivot,tmp_de)
                #
                io.puts "\"#{lang_P}#{tmp_pivot}\"->\"#{lang_B}#{tmp_de}\";"
                if index==transgraph.lang_p_b[tmp_pivot].size-1
                  io2.puts "#{lang_B}#{tmp_de}\""
                else
                  io2.print "#{lang_B}#{tmp_de},"
                end
                # sleep(5)
              }
              i=i+1
            end
          }
          io.puts "}"
        end
      end
      system( "dot -Tjpg '#{output_each_trans_filename}#{i_filecount}.dot' -o #{output_each_trans_filename}#{i_filecount}.jpg" )
      i_filecount=i_filecount+1
    }
  end
end

# => 入力:"pivot","a1,a2,a3..","b1,b2,b3"となっている入力ファイル
# => 出力:出力ファイルに「トランスグラフのpivotが2以上、ノードが7以上」という条件を満たしたトランスグラフごとの
# => png,dot,csvを connected_components/each_trans/ 以下にファイル出力

def measure_share_ratio_from_each_trans
  which_lang="JaToEn_EnToDe"
  # which_lang="Ind_Mnk_Zsm_new"
  # which_lang="Zh_Uy_Kz"
  # input_filename="share_ratio/#{which_lang}.csv"
  input_filename="connected_components/each_trans_#{which_lang}/#{which_lang}"
  answer_filename="answer/answer_UK_1122.csv"
  output_filename="connected_components/measured/#{which_lang}.csv"
  output_each_trans_filename="connected_components/measured/#{which_lang}/"


  # transgraph = Transgraph.new(input_filename)
  answer = Answer.new(answer_filename)

  #transgraph情報を画像表示
  i_filecount=0

  for i_filecount in 0 .. 2000

    transgraph = Transgraph.new("#{input_filename}_subgraph_#{i_filecount}.csv")

    # 空の有向グラフを作る
    g  = RGL::DirectedAdjacencyGraph.new

    # 日英独、無限再帰おこってる
    transgraph_count=0

    transgraph.pivot.each{|piv|
      tmp_p=piv[0]
      g.add_vertex(tmp_p)

      piv[1][0].each{|tmp_a|
        g.add_vertex("Ja-#{tmp_a}")
        g.add_edge("En-#{tmp_p}","Ja-#{tmp_a}")
      }
      piv[1][1].each{|tmp_b|
        g.add_vertex("De-#{tmp_b}")
        g.add_edge("En-#{tmp_p}","De-#{tmp_b}")
      }
      transgraph_count+=1
    }

    passed_transgraphs = []

    # 「トランスグラフのpivotが2以上、ノードが7以上」という条件を満たしたトランスグラフをpassed_transgraphsという配列にいれる
    # each_connected_componentが接続するサブグラフを返す
    g.to_undirected.each_connected_component { |connected_component|
      count_pivot=0
      if connected_component.size> 6
        connected_component.each{|c|
          if c.start_with?("En-")
            count_pivot+=1
          end
        }
        # マルダンのアプリケーションでパスするトランスグラフ
        if count_pivot>1
          passed_transgraphs <<  connected_component
        end
      end

    }

    # i_filecount=0
    i=0
    output_transgraph=[]
    passed_transgraphs.each{|passed_transgraph|
      pp passed_transgraph
      File.open("#{output_each_trans_filename}#{i_filecount}.dot", "w") do |io|
        File.open("#{output_each_trans_filename}#{i_filecount}.csv", "w") do |io2|
          io.puts "digraph #{i} {"
          io.puts "graph [rankdir = LR];"
          passed_transgraph.each{|node|
            if node.start_with?("En-")
              tmp_pivot=node[3 .. -1]
              output_transgraph[i]  = RGL::DirectedAdjacencyGraph.new
              pp tmp_pivot
              io2.print "\"#{tmp_pivot}\",\""
              # 英->日
              transgraph.lang_p_a[tmp_pivot].each_with_index{|tmp_ja,index|
                if tmp_ja.size == 0
                  next
                end
                output_transgraph[i].add_vertex(tmp_ja)
                output_transgraph[i].add_edge(tmp_pivot,tmp_ja)
                io.puts "\"#{lang_A}#{tmp_ja}\"->\"#{lang_P}#{tmp_pivot}\";"
                if index==transgraph.lang_p_a[tmp_pivot].size-1
                  io2.print "#{lang_A}#{tmp_ja}\",\""
                else
                  io2.print "#{lang_A}#{tmp_ja},"
                end
              }

              # 英->独
              transgraph.lang_p_b[tmp_pivot].each_with_index{|tmp_de,index|
                if tmp_de.size == 0
                  next
                end
                output_transgraph[i].add_vertex(tmp_de)
                output_transgraph[i].add_edge(tmp_pivot,tmp_de)
                #
                io.puts "\"#{lang_P}#{tmp_pivot}\"->\"#{lang_B}#{tmp_de}\";"
                if index==transgraph.lang_p_b[tmp_pivot].size-1
                  io2.puts "#{lang_B}#{tmp_de}\""
                else
                  io2.print "#{lang_B}#{tmp_de},"
                end
                # sleep(5)
              }
              i=i+1
            end
          }
          io.puts "}"
        end
      end
      system( "dot -Tjpg '#{output_each_trans_filename}#{i_filecount}.dot' -o #{output_each_trans_filename}#{i_filecount}.jpg" )
      i_filecount=i_filecount+1
    }
  end
end
#3言語辞書データと答えの辞書データを入力
#pivotの共有率を返す
def measure_share_ratio
  which_lang="JaToEn_EnToDe"
  # which_lang="Ind_Mnk_Zsm_new"
  # which_lang="Zh_Uy_Kz"
  # input_filename="share_ratio/#{which_lang}.csv"
  input_filename="connected_components/each_trans_#{which_lang}/#{which_lang}"
  # answer_filename="answer/answer_UK_1122.csv"
  answer_filename="answer/Ja_De.csv"
  # answer_filename="answer/U_K.csv"

  output_filename="connected_components/measured/#{which_lang}.csv"
  output_each_trans_filename="connected_components/measured/#{which_lang}/"


  # transgraph = Transgraph.new(input_filename)
  answer = Answer.new(answer_filename)

  #transgraph情報を画像表示
  pivot_connected=Set.new
  pivot_share=Set.new
  pivot_connected_num=Array.new #答えのA-Bペアのどちらかと繋がっているpivotの数
  pivot_share_num=Array.new #答えのA-Bペアの両方と繋がっているpivotの数
  share_ratio=Array.new #pivotの共有率

  for i_filecount in 0 .. 168
    transgraph = Transgraph.new("#{input_filename}_subgraph_#{i_filecount}.csv")

    #答えとなるペアそれぞれについて、以下の3つを出す
    #answer_key_value_pair=Array.new
    # pivot_connected=Set.new
    # pivot_share=Set.new
    # pivot_connected_num=Array.new #答えのA-Bペアのどちらかと繋がっているpivotの数
    # pivot_share_num=Array.new #答えのA-Bペアの両方と繋がっているpivotの数
    # share_ratio=Array.new #pivotの共有率
    answer.answer.each{|answer_key, answer_values|
      # answer_valueは配列
      answer_values.each{|answer_value|#全てのanswerのA-Bについて走査
        if transgraph.lang_a_b.has_key?(answer_key)#同じ日本語の見出し語があるか
          if transgraph.lang_a_b[answer_key].include?(answer_value)#同じドイツ語の単語があるか
            pp "#{answer_key} & #{answer_value} exists"
            #answer_keyとanswer_valueに接続する全てのpivotの集合をとる
            pp transgraph.lang_a_p[answer_key]
            pp transgraph.lang_b_p[answer_value]
            pivot_connected=transgraph.lang_a_p[answer_key] + transgraph.lang_b_p[answer_value]#setの和部分
            pivot_connected_num.push(pivot_connected.size)#answer_valueとanswer_keyと接続しているpivot
            pivot_share=transgraph.lang_a_p[answer_key] & transgraph.lang_b_p[answer_value]#setの共通部分
            pivot_share_num.push(pivot_share.size)
            # pp pivot_share_num[-1].fdiv(pivot_connected_num[-1])
            p "#{pivot_share_num[-1]}/#{pivot_connected_num[-1]}"
            share_ratio.push(pivot_share_num[-1].fdiv(pivot_connected_num[-1])) #pivotの共有率
          else
            pp "#{answer_key} & #{answer_value} doent exists"
          end


        end
      }

    }
  end
  puts share_ratio.inject(0.0){|r,i| r+=i }/share_ratio.size
  pp pivot_connected_num
  pp pivot_share_num

end

def measure_share_ratio_of_transgraph
  which_lang="JaToEn_EnToDe"
  # which_lang="Ind_Mnk_Zsm_new"
  # which_lang="Zh_Uy_Kz"
  # input_filename="share_ratio/#{which_lang}.csv"
  input_filename="connected_components/each_trans_#{which_lang}/#{which_lang}"
  # answer_filename="answer/answer_UK_1122.csv"
  answer_filename="answer/Ja_De.csv"
  # answer_filename="answer/U_K.csv"

  output_filename="connected_components/measured/#{which_lang}.csv"
  output_each_trans_filename="connected_components/measured/#{which_lang}/"


  # transgraph = Transgraph.new(input_filename)
  answer = Answer.new(answer_filename)

  #transgraph情報を画像表示
  pivot_connected=Set.new
  pivot_share=Set.new
  pivot_connected_num=Array.new #答えのA-Bペアのどちらかと繋がっているpivotの数
  pivot_share_num=Array.new #答えのA-Bペアの両方と繋がっているpivotの数
  share_ratio=Array.new #pivotの共有率
  answer_ja_set=Set.new


  for i_filecount in 0 .. 168
    transgraph = Transgraph.new("#{input_filename}_subgraph_#{i_filecount}.csv")

    #答えとなるペアそれぞれについて、以下の3つを出す
    #answer_key_value_pair=Array.new
    # pivot_connected=Set.new
    # pivot_share=Set.new
    # pivot_connected_num=Array.new #答えのA-Bペアのどちらかと繋がっているpivotの数
    # pivot_share_num=Array.new #答えのA-Bペアの両方と繋がっているpivotの数
    # share_ratio=Array.new #pivotの共有率
    transgraph.pivot.each{|pivot|
      # answer_valueは配列
      transgraph.lang_p_a[pivot].each{|lang_a|
        transgraph.lang_p_b[pivot].each{|lang_b|
        if answer[lang_a]#同じ日本語の見出し語があるか
          if transgraph.lang_a_b[lang_b].include?(lang_a)#同じドイツ語の単語があるか
            pp "#{lang_b} & #{lang_a} exists"
            #lang_bとlang_aに接続する全てのpivotの集合をとる
            pp transgraph.lang_a_p[lang_b]
            pp transgraph.lang_b_p[lang_a]
            pivot_connected=transgraph.lang_a_p[lang_b] + transgraph.lang_b_p[lang_a]#setの和部分
            pivot_connected_num.push(pivot_connected.size)#lang_aとlang_bと接続しているpivot
            pivot_share=transgraph.lang_a_p[lang_b] & transgraph.lang_b_p[lang_a]#setの共通部分
            pivot_share_num.push(pivot_share.size)
            # pp pivot_share_num[-1].fdiv(pivot_connected_num[-1])
            p "#{pivot_share_num[-1]}/#{pivot_connected_num[-1]}"
            share_ratio.push(pivot_share_num[-1].fdiv(pivot_connected_num[-1])) #pivotの共有率
          else
            pp "#{lang_b} & #{lang_a} doent exists"
          end


        end
      }
    }

    }
  end
  puts share_ratio.inject(0.0){|r,i| r+=i }/share_ratio.size
  pp pivot_connected_num
  pp pivot_share_num

end

main
