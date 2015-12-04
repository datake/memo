require 'rgl/base'
require 'rgl/adjacency'
require 'rgl/connected_components'
require 'csv'
require 'pp'
require 'logger'
require 'set'
require 'rgl/dot'

LANG_A="Mnk_"
LANG_B="Zsm_"
LANG_P="Ind_"
def main
  get_connected_component
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

# => 入力:"pivot","a1,a2,a3..","b1,b2,b3"となっている入力ファイル
# => 出力:出力ファイルに「トランスグラフのpivotが2以上、ノードが7以上」という条件を満たしたトランスグラフごとの
# => png,dot,csvを connected_components/each_trans/ 以下にファイル出力

def get_connected_component
  # which_lang="JaToEn_EnToDe"
  which_lang="Ind_Mnk_Zsm_new"
  input_filename="share_ratio/#{which_lang}.csv"
  # answer_filename="answer_Mnk_Zsm.csv"
  output_filename="connected_components/#{which_lang}.csv"
  output_each_trans_filename="connected_components/each_trans/#{which_lang}"


  transgraph = Transgraph.new(input_filename)
  # answer = Answer.new(answer_filename)

  # 空の有向グラフを作る
  g  = RGL::DirectedAdjacencyGraph.new

  # 日英独、無限再帰おこってる？
  transgraph_count=0
  # ~5000 ok
  # ~6000 fail
  # 5000~6000 fail
  # 6000~ fail
  # 7000~ fail
  # 8000~ok

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
                io2.print "#{LANG_A}#{tmp_ja}\",\""
              else
                io2.print "#{LANG_A}#{tmp_ja},"
              end
            }

            # 英->独
            transgraph.lang_p_b[tmp_pivot].each_with_index{|tmp_de,index|
              output_transgraph[i].add_vertex(tmp_de)
              output_transgraph[i].add_edge(tmp_pivot,tmp_de)
              #
              io.puts "\"#{LANG_P}#{tmp_pivot}\"->\"#{LANG_B}#{tmp_de}\";"
              if index==transgraph.lang_p_b[tmp_pivot].size-1
                io2.puts "#{LANG_B}#{tmp_de}\""
              else
                io2.print "#{LANG_B}#{tmp_de},"
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

main
