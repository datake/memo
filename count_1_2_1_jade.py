# e*- encoding:utf-8 -*-
import networkx as nx
# import matplotlib.pyplot as plt
import pygraphviz as pgv
import csv
from pprint import pprint

#日英独で総ノード数4,ピボット2の場合を出力

G=nx.Graph()
which_lang="JaToEn_EnToDe"
input_filename="joined/"+which_lang+".csv"
output_each_trans_filename="partition_graph1210/"+which_lang+"/"+which_lang

with open(input_filename, 'r') as f:
    dataReader = csv.reader(f)
    for row in dataReader:
        # print row[0]
        if len(row)==3:
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

graphs = nx.connected_component_subgraphs(G)

subgraph_count=0
pass_subgraph_count=0

for subgraph in graphs:
    lang=nx.get_node_attributes(subgraph,'lang') # <-この処理遅い
    subgraph_count+=1
    flag=0

    if 4 == len(subgraph):
        pivot_count=0
        for node in subgraph.nodes():
            if lang[node]=='En':
                pivot_count+=1

        if pivot_count ==2:
            pass_subgraph_count+=1
            for node in subgraph.nodes():
                ja_neighbors_pivot = set()
                de_neighbors_pivot = set()

                if lang[node]=='En':
                    # pprint(node)

                    if flag==0:
                        en_string=node
                        flag=1
                    else:
                        en_string2=node

                    for node_ja_de in subgraph.neighbors(node):
                        if lang[node_ja_de]=='Ja':
                            ja_neighbors_pivot.add(node_ja_de)
                            # pprint(node_ja_de)
                            ja_string=node_ja_de
                        elif lang[node_ja_de]=='De':
                            de_neighbors_pivot.add(node_ja_de)
                            # pprint(node_ja_de)
                            de_string=node_ja_de

            print(ja_string+","+en_string+","+en_string2+","+de_string)
