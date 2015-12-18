# -*- encoding:utf-8 -*-
import networkx as nx
import matplotlib.pyplot as plt
import pygraphviz as pgv
import csv
import metis
from pprint import pprint

#大きなトランスグラフを読み取り、分割してcsvで返す
# partition_N=30
partition_N=150


# input_filename="partition_graph1210/JaToEn_EnToDe/JaToEn_EnToDe_subgraph_0.csv"
input_filename="partition_graph1210/Zh_Uy_Kz/Zh_Uy_Kz_subgraph_0.csv"

# output_filename="partition_big/"+str(partition_N)+"_"+which_lang+".csv"
# output_filename="partition_graph1210/big_JaToEn_EnToDe/"+str(partition_N)+"_EJD.csv"
output_filename="partition_graph1210/big_Zh_Uy_Kz/"+str(partition_N)+"_ZUK.csv"
output_partitioned_all="partition_graph1210/zuk_all_"+str(partition_N)+"partitioned.csv"

f = open(input_filename, 'rb')
dataReader = csv.reader(f)
node_id=0
# Gのノードはnode_idが一意で、lang,word,transnumの属性をもつ
G=nx.Graph()
partition_G=nx.Graph() #枝は後でつなぐ
for row in dataReader:
    # print row[0]
    # G.add_node(row[0],lang='En',word=row[0])
    G.add_node(node_id,{'lang':'En','word':row[0]})
    partition_G.add_node(node_id,{'lang':'En','word':row[0]})
    en_node_id=node_id
    node_id+=1

    # G.graph[row[0]]='English'
    row1_separate =row[1].split(',')
    row2_separate =row[2].split(',')
    for lang_a in row1_separate:
         if lang_a:
            G.add_node(node_id,{'lang':'Ja','word':lang_a})
            partition_G.add_node(node_id,{'lang':'Ja','word':lang_a})
            node_id+=1
            G.add_edge(node_id,en_node_id)
            # pprint(lang_a)

    for lang_b in row2_separate:
         if lang_b:
            G.add_node(node_id,{'lang':'De','word':lang_b})
            partition_G.add_node(node_id,{'lang':'De','word':lang_b})
            node_id+=1
            G.add_edge(node_id,en_node_id)
            # pprint(lang_b)

f.close()



# グラフ分割
# partsはintのlist
(edgecuts, parts) = metis.part_graph(G,nparts=partition_N, recursive=True)

for i, part in enumerate(parts): #each_with_index
    # print "******************************"
    # pprint(i)
    if G.node[i]:
        pprint(G.node[i]['word'])
        G.node[i]['transnum']=part
        partition_G.node[i]['transnum']=part
        # print "part:"
        # pprint(part) #int
lang=nx.get_node_attributes(G,'lang')
word=nx.get_node_attributes(G,'word')
transnum=nx.get_node_attributes(G,'transnum')

#transnumが同じならpartition_Gにも枝をつける
for n1, n2 in G.edges_iter():
    if G.node[n1] and G.node[n2]:
        if G.node[n1]['transnum'] != G.node[n2]['transnum'] :
            print G.node[n1]['word'], G.node[n1]['transnum']
            print G.node[n2]['word'], G.node[n2]['transnum']
            # G.remove_edge(n1,n2)
        else:
            # print G.node[n1]['word'], G.node[n1]['transnum']
            # print G.node[n2]['word'], G.node[n2]['transnum']
            partition_G.add_edge(n1,n2)

lang=nx.get_node_attributes(partition_G,'lang')
word=nx.get_node_attributes(partition_G,'word')
transnum=nx.get_node_attributes(partition_G,'transnum')

with open(output_filename, "w") as file:
    # for subgraph in parts:
    for i_node,node in enumerate(partition_G.nodes()):
        ja_neighbors_pivot = set()
        de_neighbors_pivot = set()
        if lang[node]=='En':
            print str(i_node)+"/"+str(len(partition_G.nodes()))
            pprint(word[node])
            for node_ja_de in partition_G.neighbors(node):
                if lang[node_ja_de]=='Ja':
                    ja_neighbors_pivot.add(node_ja_de)
                elif lang[node_ja_de]=='De':
                    de_neighbors_pivot.add(node_ja_de)

            #枝を切ったので、pivotにたいして日本語orドイツ語が存在しない場合がありうる
            if ja_neighbors_pivot and de_neighbors_pivot:
                file.write("\""+word[node]+"\",\"")
                last = len(ja_neighbors_pivot) - 1
                for i,ja in enumerate(ja_neighbors_pivot):
                    if i == last:
                        file.write(word[ja]+"\",\"")
                    else:
                        file.write(word[ja]+",")

                last = len(de_neighbors_pivot) - 1
                for i,de in enumerate(de_neighbors_pivot):
                    if i == last:
                        file.write(word[de]+"\"\n")
                    else:
                        file.write(word[de]+",")
