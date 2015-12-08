# e*- encoding:utf-8 -*-
import networkx as nx
# import matplotlib.pyplot as plt
import pygraphviz as pgv
import csv
import metis
import pydot
from pprint import pprint

vector = {}

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
    vector[row[0]] = []
    row1_separate =row[1].split(',')
    row2_separate =row[2].split(',')
    for lang_a in row1_separate:
        vector[row[0]].append(lang_a)
        G.add_node(lang_a,lang='Ja')
        G.add_edge(lang_a,row[0])
        pprint(lang_a)

    for lang_b in row2_separate:
        vector[row[0]].append(lang_b)
        G.add_node(lang_b,lang='De')
        G.add_edge(lang_b,row[0])
        pprint(lang_b)

f.close()


graphs = nx.connected_component_subgraphs(G)

i=0

for subgraph in graphs:
    # print(G.adj)
    print "*********************subgraph number:"+str(i)+"***************************"
    print "*********************subgraph node数:"+str(len(subgraph))+"***************************"
    # if len(subgraph)<30000: #大きいトランスグラフをとばす場合はコメントアウト外す
    if 6 < len(subgraph): #!!!
        with open(output_each_trans_filename+"_subgraph_"+str(i)+".csv", "w") as file:

            for node in subgraph.nodes():
                ja_neighbors_pivot = set()
                de_neighbors_pivot = set()
                lang=nx.get_node_attributes(subgraph,'lang')
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

        i+=1
