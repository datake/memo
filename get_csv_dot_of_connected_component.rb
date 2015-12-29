require 'rgl/base'
require 'rgl/adjacency'
require 'rgl/connected_components'
require 'csv'
require 'pp'
require 'logger'
require 'set'
require 'rgl/dot'

# LANG_A="Uy_"
# LANG_B="Kz_"
# LANG_P="Zh_"
LANG_A="Mnk_"
LANG_B="Zsm_"
LANG_P="Ind_"
def main
  make_dot_img_from_each_trans
  # get_csv_dot_of_connected_component
  # get_pass_pivot
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
      if row.size  == 3
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
    @answer = {}
    @answer_head_trans = Hash.new {|h,k| h[k]=[]}
    CSV.foreach(answer_filename) do |row|
      @answer[row[0]]=row[1..-1]
      if row[0 .. -1].size>1
        row[1..-1].each{|trans|
          if answer_head_trans.has_key?(trans)
            answer_head_trans[trans] << row[0]
            #まだ登録されていないkeyならvalueに追加
          else
            answer_head_trans[trans] << row[0]
          end
        }
      end
    end
  end
  attr_accessor :answer
  attr_accessor :answer_head_trans
end

def split_comma_to_array (text)
  # text=text.gsub(/"/, '')
  lang_arr=text.split(",")
  return lang_arr
end


#すでに繋がっているトランスグラフごとに分離されているファイルから
#dotや画像を出力
#TODO:Ind_Mnk_Zsmの答え自動チェック
def make_dot_img_from_each_trans
  # languages = ["JaToEn_JaToDe","JaToEn_EnToDe","JaToDe_DeToEn","Zh_Uy_Kz"]
  languages = ["JaToEn_JaToDe","JaToEn_EnToDe","JaToDe_DeToEn"]
  # language="JaToEn_JaToDe"
  languages.each{|language|
    # language="JaToEn_JaToDe"
    # language="Ind_Mnk_Zsm_new"
    # language="Zh_Uy_Kz"
    output_filename="visualize_1230/csv/#{language}.csv"
    output_each_trans_filename="visualize_1230/#{language}/"

    if language=="Ind_Mnk_Zsm"
      answer_filename="answer/Mnk_Zsm.csv"
      input_filename="partition_graph_1227/"+language+"/"+language+"_subgraph_"
      # Ind_Mnk_Zsmだけ大規模トランスグラフがないから0番目も表示する
      max=155
      lang_A="Mnk_"
      lang_B="Zsm_"
      lang_P="Ind_"
    elsif language=="JaToEn_JaToDe"
      input_filename="partition_graph_1227/"+language+"/"+language+"_subgraph_"
      answer_filename="answer/En_De.csv"
      answer_filename2="answer/De_En.csv"

      lang_A="En_"
      lang_B="De_"
      lang_P="Ja_"
      max=389
    elsif language=="JaToEn_EnToDe"
      max=453
      input_filename="partition_graph_1227/"+language+"/"+language+"_subgraph_"
      answer_filename="answer/Ja_De.csv"
      answer_filename2="answer/De_Ja.csv"

      lang_A="Ja_"
      lang_B="De_"
      lang_P="En_"
    elsif language=="Zh_Uy_Kz"
      max=1457
      input_filename="partition_graph_1227/#{language}/#{language}_subgraph_"
      answer_filename="answer/Uy_Kz.csv"
      lang_A="Uy_"
      lang_B="Kk_"
      lang_P="Zh_"
    elsif language=="JaToDe_DeToEn"
      max=364
      input_filename="partition_graph_1227/#{language}/#{language}_subgraph_"
      answer_filename="answer/Ja_En.csv"
      answer_filename2="answer/En_Ja.csv"

      lang_A="Ja_"
      lang_B="En_"
      lang_P="De_"
    end
    answer = Answer.new(answer_filename)
    if languages == "JaToEn_JaToDe" || languages == "JaToEn_EnToDe" || languages == "JaToDe_DeToEn"
        answer2 = Answer.new(answer_filename2)
    end
    #0番目は巨大なので指定するとstack level too deepになる
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
        if connected_component.size>= 4
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
        # pp passed_transgraph
        File.open("#{output_each_trans_filename}#{i_filecount}.dot", "w") do |io|
          File.open("#{output_each_trans_filename}#{i_filecount}.csv", "w") do |io2|
            io.puts "digraph #{i} {"
            io.puts "graph [rankdir = LR];"
            passed_transgraph.each{|node|

              #答えペアに色付け
              if node.start_with?("Ja-")
                node_a=node[3 .. -1] #Aノード
                if answer.answer[node_a] && transgraph.lang_a_b[node_a]
                  answerandb =answer.answer[node_a] & transgraph.lang_a_b[node_a]
                  if ! answerandb.empty?
                    color = "%06x" % (rand * 0xffffff)
                    io.puts "\"#{lang_A}#{node_a}\" [penwidth=5 color = \"\##{color}\"];"
                    answerandb.each{|node_b|
                      io.puts "\"#{lang_B}#{node_b}\" [penwidth=5 color = \"\##{color}\"];"
                      io.puts "\"#{lang_A}#{node_a}\"->\"#{lang_B}#{node_b}\" [style = dashed color = \"\##{color}\" dir = none];"
                    }

                  end
                end
              end

              #二つ目の辞書でも色付け
              if languages == "JaToEn_JaToDe" || languages == "JaToEn_EnToDe" || languages == "JaToDe_DeToEn"
                if node.start_with?("De-")
                  node_b=node[3 .. -1] #Bノード
                  if answer2.answer[node_b] && transgraph.lang_b_a[node_b]
                    answeranda =answer2.answer[node_b] & transgraph.lang_b_a[node_b]
                    if ! answeranda.empty?
                      color = "%06x" % (rand * 0xffffff)
                      io.puts "\"#{lang_B}#{node_b}\" [penwidth=5 color = \"\##{color}\"];"
                      answerandb.each{|node_a|
                        io.puts "\"#{lang_A}#{node_a}\" [penwidth=5 color = \"\##{color}\"];"
                        io.puts "\"#{lang_A}#{node_a}\"->\"#{lang_B}#{node_b}\" [style = dashed color = \"\##{color}\" dir = none];"
                      }

                    end
                  end
                end
              end

              if node.start_with?("En-")
                tmp_pivot=node[3 .. -1]
                output_transgraph[i]  = RGL::DirectedAdjacencyGraph.new
                io2.print "\"#{tmp_pivot}\",\""
                # 英->日
                transgraph.lang_p_a[tmp_pivot].each_with_index{|tmp_ja,index|
                  if tmp_ja.size == 0
                    next
                  end
                  output_transgraph[i].add_vertex(tmp_ja)
                  output_transgraph[i].add_edge(tmp_pivot,tmp_ja)

                  #dot言語記述(英->日)
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
                  #dot言語記述(英->独)
                  io.puts "\"#{lang_P}#{tmp_pivot}\"->\"#{lang_B}#{tmp_de}\";"
                  if index==transgraph.lang_p_b[tmp_pivot].size-1
                    io2.puts "#{lang_B}#{tmp_de}\""
                  else
                    io2.print "#{lang_B}#{tmp_de},"
                  end
                }
                i=i+1
              end
            }
            io.puts "}"
          end
        end
        system( "dot -Tjpg '#{output_each_trans_filename}#{i_filecount}.dot' -o #{output_each_trans_filename}#{i_filecount}.jpg" )
        # i_filecount=i_filecount+1
        pp i_filecount
      }
    end
  }
end


# => 入力:"pivot","a1,a2,a3..","b1,b2,b3"となっている入力ファイル
# => 出力:出力ファイルに「トランスグラフのpivotが2以上、ノードが7以上」という条件を満たしたトランスグラフごとの
# => png,dot,csvを connected_components/each_trans/ 以下にファイル出力
# => 日独、ウイグルカザフなどのグラフ数の多いデータはeach_connected_componentでstack level too deepのエラー出るので
# => 実質インドネシアのデータでしか使えない。
# => 今後Pythonのnetworkxのconnected_component_subgraphsを使う

def get_csv_dot_of_connected_component
  # which_lang="JaToEn_EnToDe"
  # which_lang="Ind_Mnk_Zsm_new"
  which_lang="Zh_Uy_Kz"
  # input_filename="share_ratio/#{which_lang}.csv"
  input_filename="simulation/csv/2-4-4.csv"
  # output_filename="connected_components1208/#{which_lang}.csv"
  # output_each_trans_filename="connected_components1208/test/#{which_lang}"
  output_filename="simulation/2-4-4.csv"
  output_each_trans_filename="simulation/image/2-4-4/2-4-4"

  transgraph = Transgraph.new(input_filename)

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

  # 「トランスグラフのpivotが2以上、ノードが4以上」という条件を満たしたトランスグラフをpassed_transgraphsという配列にいれる
  # each_connected_componentが接続するサブグラフを返す
  g.to_undirected.each_connected_component { |connected_component|
    count_pivot=0
    if connected_component.size>=4
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

  pp passed_transgraphs
  # ファイル出力するものを選別
  # pivotだけ出力編
  passed_pivot=[]
  passed_transgraphs.each{|passed_transgraph|
    passed_transgraph.each{|node|
      if node.start_with?("En-")
        passed_pivot << node[3 .. -1] #En-以降の文字列を入れる
      end
    }
  }
  passed_pivot.sort!

  File.open(output_filename, "w") do |io|
    passed_pivot.each{|tmp_pivot|
      io.puts tmp_pivot
    }
  end

  #transgraph情報をファイル出力
  i=0
  i_filecount=0
  output_transgraph=[]
  passed_transgraphs.each{|passed_transgraph|
    pp passed_transgraph
    File.open("#{output_each_trans_filename}_#{i_filecount}.dot", "w") do |io|
      File.open("#{output_each_trans_filename}_#{i_filecount}.csv", "w") do |io2|
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
              output_transgraph[i].add_vertex(tmp_ja)
              output_transgraph[i].add_edge(tmp_pivot,tmp_ja)
              io.puts "\"#{LANG_A}#{tmp_ja}\"->\"#{LANG_P}#{tmp_pivot}\";"
              if index==transgraph.lang_p_a[tmp_pivot].size-1
                io2.print "#{tmp_ja}\",\""
              else
                io2.print "#{tmp_ja},"
              end
            }

            # 英->独
            transgraph.lang_p_b[tmp_pivot].each_with_index{|tmp_de,index|
              output_transgraph[i].add_vertex(tmp_de)
              output_transgraph[i].add_edge(tmp_pivot,tmp_de)
              #
              io.puts "\"#{LANG_P}#{tmp_pivot}\"->\"#{LANG_B}#{tmp_de}\";"
              if index==transgraph.lang_p_b[tmp_pivot].size-1
                io2.puts "#{tmp_de}\""
              else
                io2.print "ge#{tmp_de},"
              end
              # sleep(5)
            }
            i=i+1
          end
        }
        io.puts "}"
      end
    end
    system( "dot -Tjpg '#{output_each_trans_filename}_#{i_filecount}.dot' -o #{output_each_trans_filename}_#{i_filecount}.jpg" )
    i_filecount=i_filecount+1
  }
end

# => rglのconnected_componentが階層が深すぎるエラーがでたため、その対処をしようとしてWIP
# => Pythonのnetworkxのconnected_componentを取得する関数ではうまくいけたので今後そっちを使う
def get_pass_pivot #WIP
  which_lang="JaToEn_EnToDe"
  # which_lang="Ind_Mnk_Zsm_new"
  # which_lang="Zh_Uy_Kz"
  input_filename="share_ratio/#{which_lang}.csv"
  # answer_filename="answer_Mnk_Zsm.csv"
  output_filename="connected_components/#{which_lang}_pass_pivot.csv"
  output_each_trans_filename="connected_components/each_trans/#{which_lang}"
  divide_k=20 #ZUKは10分割してもと計算深すぎてできない

  transgraph = Transgraph.new(input_filename)
  passed_pivot=Set.new
  transgraph_count=0

  divided_transgraph=transgraph.pivot.each_slice(1000).to_a #1000個ずつの配列に変換
  combi_transgraph_pivot=[]
  tmp=0
  pp divided_transgraph.size
  divided_transgraph.combination(2){|a, b|
    # 空の有向グラフを作る
    g  = RGL::DirectedAdjacencyGraph.new
    begin
      # pp a
      tmp+=1
      pp tmp
      combi_transgraph_pivot<<a
      combi_transgraph_pivot<<b
      combi_transgraph_pivot<<c
      # ここから繰り返し
      combi_transgraph_pivot.each{|combi_tr_pi|
        combi_tr_pi.each{|piv|
          # pp piv
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
      }

      passed_transgraphs = []

      # 「トランスグラフのpivotが2以上、ノードが7以上」という条件を満たしたトランスグラフをpassed_transgraphsという配列にいれる
      # each_connected_componentが接続するサブグラフを返す
      g.to_undirected.each_connected_component { |connected_component|
        count_pivot=0
        if connected_component.size>= 4
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

      # pp passed_transgraphs
      # ファイル出力するものを選別
      # pivotだけ出力編

      passed_transgraphs.each{|passed_transgraph|
        passed_transgraph.each{|node|
          if node.start_with?("En-")
            passed_pivot << node[3 .. -1] #En-以降の文字列を入れる
          end
        }
      }
    rescue => error
      pp error
      # next
    end
  }
  # ここまで繰り返し
  passed_pivot.sort!

  File.open(output_filename, "w") do |io|
    passed_pivot.each{|tmp_pivot|
      io.puts tmp_pivot
    }
  end

end

main
