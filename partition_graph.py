# e*- encoding:utf-8 -*-
import networkx as nx
# import matplotlib.pyplot as plt
import pygraphviz as pgv
import csv
import metis
import pydot
from pprint import pprint

#トランスグラフのcsvデータを入力として、
#もともと繋がっているトランスグラフデータに分けて
#トランスグラフの数の分csv出力(切断はしない)

G=nx.Graph()
# which_lang="JaToEn_EnToDe"
# which_lang="Ind_Mnk_Zsm_new"
which_lang="Zh_Uy_Kz"
input_filename="share_ratio/"+which_lang+".csv"
output_each_trans_filename="connected_components1208/each_trans_"+which_lang+"/"+which_lang

f = open(input_filename, 'rb')
dataReader = csv.reader(f)
for row in dataReader:
    # print row[0]
    G.add_node(row[0],lang='En')
    # G.graph[row[0]]='English'
    row1_separate =row[1].split(',')
    row2_separate =row[2].split(',')
    for lang_a in row1_separate:
        G.add_node(lang_a,lang='Ja')
        G.add_edge(lang_a,row[0])
        # pprint(lang_a)

    for lang_b in row2_separate:
        G.add_node(lang_b,lang='De')
        G.add_edge(lang_b,row[0])
        # pprint(lang_b)

f.close()


graphs = nx.connected_component_subgraphs(G)

subgraph_count=0
pass_subgraph_count=0

for subgraph in graphs:
    lang=nx.get_node_attributes(subgraph,'lang') # <-この処理遅い
    print "*********************subgraph number:"+str(pass_subgraph_count)+"("+str(subgraph_count)+")***************************"
    subgraph_count+=1
    print "*********************subgraph node数:"+str(len(subgraph))+"***************************"
    # if len(subgraph)<30000: #大きいトランスグラフをとばす場合はコメントアウト外す
    if 6 < len(subgraph): #!!! ノード数の制限
        # ピボット数の制限
        pivot_count=0
        for node in subgraph.nodes():
            if lang[node]=='En':
                pivot_count+=1

        if pivot_count > 1:
            with open(output_each_trans_filename+"_subgraph_"+str(pass_subgraph_count)+".csv", "w") as file:
                pass_subgraph_count+=1
                for node in subgraph.nodes():
                    ja_neighbors_pivot = set()
                    de_neighbors_pivot = set()
                    if lang[node]=='En':
                        pprint(node)
                        for node_ja_de in subgraph.neighbors(node):
                            if lang[node_ja_de]=='Ja':
                                ja_neighbors_pivot.add(node_ja_de)
                            elif lang[node_ja_de]=='De':
                                de_neighbors_pivot.add(node_ja_de)

                        file.write("\""+node+"\",\"")
                        last = len(ja_neighbors_pivot) - 1
                        for i,ja in enumerate(ja_neighbors_pivot):
                            if i == last:
                                file.write(ja+"\",\"")
                            else:
                                file.write(ja+",")

                        last = len(de_neighbors_pivot) - 1
                        for i,de in enumerate(de_neighbors_pivot):
                            if i == last:
                                file.write(de+"\"\n")
                            else:
                                file.write(de+",")
