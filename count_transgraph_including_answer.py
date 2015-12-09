# e*- encoding:utf-8 -*-
import networkx as nx
# import matplotlib.pyplot as plt
import pygraphviz as pgv
import csv
import metis
import pydot
from pprint import pprint

#1つのトランスグラフのcsvデータを入力として、
#要素数が MINIMUM_TRANS_NODES 以上のトランスグラフや
#正解データを含むトランスグラフの数を出力(分割はしない)

G=nx.Graph()
which_lang="JaToEn_EnToDe"
# which_lang="Ind_Mnk_Zsm_new"
# which_lang="Zh_Uy_Kz"
input_filename="share_ratio/"+which_lang+".csv"
# output_each_trans_filename="connected_components1208/each_trans_"+which_lang+"/"+which_lang
output_each_trans_filename="partition_and_count1209/"+which_lang
# answer="answer/Mnk_Zsm.csv"
# answer="answer/answer_UK_1122.csv"
answer="answer/Ja_De.csv"
MINIMUM_TRANS_NODES=3




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

# 答えデータ読み込み
answer_dict={}
f = open(answer, 'rb')
dataReader = csv.reader(f)
for row in dataReader:
    answer_dict[row[0]]=row[1]

graphs = nx.connected_component_subgraphs(G)

subgraph_count=0
pass_subgraph_count=0
count_trans_include_answer=0

for subgraph in graphs:
    count_trans_flag=0
    lang=nx.get_node_attributes(subgraph,'lang') # <-この処理遅い

    if MINIMUM_TRANS_NODES < len(subgraph):
        pivot_count=0
        ja_tmp=0
        de_tmp=0
        for node in subgraph.nodes():
            if lang[node]=='En':
                pivot_count+=1

            if lang[node]=='Ja':
                ja_tmp+=1

            if lang[node]=='De':
                de_tmp+=1

        if pivot_count > 0 and ja_tmp>0 and de_tmp>0: #３言語もつトランスグラフ
            print "*********************subgraph number:"+str(pass_subgraph_count)+"("+str(subgraph_count)+")***************************"
            subgraph_count+=1
            print "*********************subgraph node数:"+str(len(subgraph))+"***************************"
            pass_subgraph_count+=1
            for node in subgraph.nodes():
                if count_trans_flag==0:
                    ja_neighbors_pivot = set()
                    de_neighbors_pivot = set()
                    if lang[node]=='En':
                        pprint(node)
                        for node_ja_de in subgraph.neighbors(node):
                            if lang[node_ja_de]=='Ja':
                                ja_neighbors_pivot.add(node_ja_de)

                            elif lang[node_ja_de]=='De':
                                de_neighbors_pivot.add(node_ja_de)

                        last = len(ja_neighbors_pivot) - 1
                        for i,ja in enumerate(ja_neighbors_pivot):
                            if count_trans_flag==0:
                                if answer_dict.has_key(ja):
                                    count_trans_include_answer+=1
                                    count_trans_flag=1


print "count_trans_include_answer:"
print count_trans_include_answer

print "トランスグラフ数"
print str(len(graphs))
