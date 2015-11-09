require 'csv'
require 'pp'
require 'logger'
require 'set'

def array_initialize(node_count,str)
  arr = []
  node_count.to_i.times do |count|
    arr.push("#{str}#{count}")
  end
  return arr
end

def main
  puts "ピボットのノード数"
  p_node=$stdin.gets.chomp
  puts "入力辞書Aのノード数"
  a_node=$stdin.gets.chomp
  puts "入力辞書Bのノード数"
  b_node=$stdin.gets.chomp
  day = Time.now
  output_filename="simulation/#{p_node}-#{a_node}-#{b_node}.csv"
  log = Logger.new("simulation/simulation_error.log")

  p_combination=Array.new
  a_combination=Array.new
  b_combination=Array.new
  sets_of_nodes=Set.new
  transgraphs=Array.new

  for p in 0 .. (p_node.to_i-1) do
    p_combination[p]=array_initialize(p_node,"p").combination(p+1).to_a
  end

  for a in 0 .. (a_node.to_i-1) do
    a_combination[a]=array_initialize(a_node,"a").combination(a+1).to_a
  end

  for b in 0 .. (b_node.to_i-1) do
    b_combination[b]=array_initialize(b_node,"b").combination(b+1).to_a
  end

  #pivot_count=0

  #sets_of_nodesにとりうる情報をセット
  for a in 0 .. a_combination.size-1 do
    for b in 0 .. b_combination.size-1 do
      #begin
        a_combination[a].each{|a_array|
          b_combination[b].each{|b_array|
            (p_combination.size-1).times do |p|
              sets_of_nodes<<[a_array,b_array]#push
            end
          }
         }
      # rescue => error
      #   log.error(error.message)
      #   next
      # end
    end
  end
  pp sets_of_nodes
  pivot_count=0
  # begin
    File.open(output_filename, "w") do |io|
      sets_of_nodes.each{|set_of_nodes|

        a_set=set_of_nodes[0]
        b_set=set_of_nodes[1]


        #if a_set.size==a_node.to_i && b_set.size==b_node.to_i
        sets_of_nodes.delete(set_of_nodes)#自分と自分よりうしろのもの全てを比較
          sets_of_nodes.each{|search_nodes|
            #同じAまたは同じBを含むものは同一transgraph
            if (set_of_nodes[0] & search_nodes[0]).size + (set_of_nodes[1] & search_nodes[1]).size >0
              #指定した全てのノードを含まなければいけない
              #arrayの和集合は|で表現
              if (set_of_nodes[0] | search_nodes[0] | set_of_nodes[1] | search_nodes[1]).size==(a_node.to_i+b_node.to_i)
                io.puts("\"pivot-#{pivot_count}-1\",\"#{a_set.to_a.join(",")}\",\"#{b_set.to_a.join(",")}\"")
                io.puts("\"pivot-#{pivot_count}-2\",\"#{search_nodes[0].to_a.join(",")}\",\"#{search_nodes[1].to_a.join(",")}\"")
                pivot_count=pivot_count+1
              end
            end

        #end
        }
      }
    end
  # rescue => error
  #   log.error(error.message)
  # end

end
main
