# e*- encoding:utf-8 -*-
import networkx as nx
# import matplotlib.pyplot as plt
import pygraphviz as pgv
import csv
# import pydot
from pprint import pprint

#トランスグラフのcsvデータを入力として、
#もともと繋がっているトランスグラフデータに分けて
#トランスグラフの数の分csv出力(切断はしない)

G=nx.Graph()
# which_lang="Ind_Mnk_Zsm"
# which_lang="Zh_Uy_Kz"
# which_lang="JaToEn_JaToDe"
# which_lang="JaToDe_DeToEn"
# which_lang="JaToEn_EnToDe0105" #なぜかInd_Mnk_Zsmだけうまくいかないからrubyでやる
which_lang="EngToDeu_EngToNld"

# input_filename="share_ratio/"+which_lang+".csv"
# input_filename="share_ratio/Z_U_K.csv"
# input_filename="share_ratio/JaToEn_JaToDe.csv"
# input_filename="share_ratio/Ind_Mnk_Zsm_new.csv"
# output_each_trans_filename="connected_components1208/each_trans_"+which_lang+"/"+which_lang

if which_lang =="Zh_Uy_Kz":
    input_filename="zuk_1125/zukTable.csv"
    output_each_trans_filename="partition_graph_1227/"+which_lang+"/"+which_lang
elif which_lang =="JaToEn_EnToDe":
    input_filename="share_ratio/"+which_lang+".csv"
    output_each_trans_filename="partition_graph_1227/"+which_lang+"/"+which_lang
elif which_lang =="Ind_Mnk_Zsm":
    # input_filename="count_node_edge/Mnk_Ind_Zsm_new_arbi_original.csv"
    input_filename="joined/Mnk_Ind_Zsm_new.csv"
    output_each_trans_filename="partition_graph_1227/Ind_Mnk_Zsm_hinsinashi/"+which_lang
elif which_lang =="JaToEn_JaToDe":
    input_filename="share_ratio/JaToEn_JaToDe.csv"
    output_each_trans_filename="partition_graph_1227/"+which_lang+"/"+which_lang
elif which_lang =="JaToDe_DeToEn":
    input_filename="joined/JaToDe_DeToEn.csv"
    output_each_trans_filename="partition_graph_1227/"+which_lang+"/"+which_lang
elif which_lang =="JaToEn_EnToDe0105":
    input_filename="0105/Ja_En_De_0105_2.csv"
    output_each_trans_filename="partition_graph_1227/"+which_lang+"/"+which_lang
elif which_lang =="EngToDeu_EngToNld":
    input_filename="input/deu-eng-nld/eng_deu_nld.csv"
    output_each_trans_filename="partition_graph_1227/"+which_lang+"/"+which_lang



with open(input_filename, 'r') as f:
    dataReader = csv.reader(f)
    for row in dataReader:
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
    print("*********************subgraph number:"+str(pass_subgraph_count)+"("+str(subgraph_count)+")***************************")
    subgraph_count+=1
    print("*********************subgraph node数:"+str(len(subgraph))+"***************************")
    # if len(subgraph)<30000: #大きいトランスグラフをとばす場合はコメントアウト外す
    if 4 <= len(subgraph): #!!! ノード数の制限
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
