# -*- encoding:utf-8 -*-
import networkx as nx
# import matplotlib.pyplot as plt
import pygraphviz as pgv
import csv
import metis
import pydot
import unicodedata
import codecs
from pprint import pprint
from unidecode import unidecode

#トランスグラフのcsvデータを入力として、
#もともと繋がっているトランスグラフデータに分けて
#それぞれのピボット共有率の計算

G=nx.Graph()
# which_lang="JaToEn_EnToDe"
# which_lang="Ind_Mnk_Zsm"
which_lang="Zh_Uy_Kz"
# input_filename="joined/Z_U_K.csv"
# input_filename="share_ratio/Ind_Mnk_Zsm_new.csv"
input_filename='share_ratio/Z_U_K_utf8.csv'

# output_each_trans_filename="connected_components1208/each_trans_"+which_lang+"/"+which_lang
output_each_trans_filename="partition_graph1210/"+which_lang+"/"+which_lang

f = open(input_filename, 'rb')
# f = codecs.open(input_filename, 'rb','utf-8')
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
    pivot_connected = set()
    pivot_share = set()
    share_ratio=set()

    pivot_connected_answer = set()
    pivot_share_answer = set()
    share_ratio_answer =set()
    # print "*********************subgraph number:"+str(pass_subgraph_count)+"("+str(subgraph_count)+")***************************"
    subgraph_count+=1
    # print "*********************subgraph node数:"+str(len(subgraph))+"***************************"
    # if len(subgraph)<30000: #大きいトランスグラフをとばす場合はコメントアウト外す
    if 6 < len(subgraph) and len(subgraph)<20: #!!! ノード数の制限
        # ピボット数の制限
        pivot_count=0
        for node in subgraph.nodes():
            if lang[node]=='En':
                pivot_count+=1

        if pivot_count > 1:
            # with open(output_each_trans_filename+"_subgraph_"+str(pass_subgraph_count)+".csv", "w") as file:
            pass_subgraph_count+=1
            ja_neighbors_pivot = set()
            de_neighbors_pivot = set()
            for node_jade in subgraph.nodes():
                if lang[node_jade]=='Ja':
                    ja_neighbors_pivot.add(node_jade)
                    # pprint(node)
                elif lang[node_jade]=='De':
                    de_neighbors_pivot.add(node_jade)
                    # pprint(node)
                    # for node_de in subgraph.nodes():
                    #     if lang[node_de]=='De':
                    #         if node_de == node_ja:
                    #             pprint (node_de)


            pprint(len(ja_neighbors_pivot))
            pprint(len(de_neighbors_pivot))

            for i_js,ja_str in enumerate(ja_neighbors_pivot):
                for i_de,de_str in enumerate(de_neighbors_pivot):

                    # if ja==de:
                    ja= ja_str.decode('utf-8')
                    de=de_str.decode('utf-8')
                    # pprint(ja)
                    # print unidecode(ja)
                    # print unidecode(de)
                    print "a"
                    if unidecode(ja) == unidecode(de):
                    # if ja.decode('utf-8')==de.decode('utf-8'):
                    # if ja==de:
                        print("the same")
