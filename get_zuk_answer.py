# -*- encoding:utf-8 -*-
import networkx as nx
import pygraphviz as pgv
import csv
import unicodedata
import codecs
import sys
from pprint import pprint
from unidecode import unidecode
def levenshtein(s1, s2):
    if len(s1) < len(s2):
        return levenshtein(s2, s1)

    # len(s1) >= len(s2)
    if len(s2) == 0:
        return len(s1)

    previous_row = range(len(s2) + 1)
    for i, c1 in enumerate(s1):
        current_row = [i + 1]
        for j, c2 in enumerate(s2):
            insertions = previous_row[j + 1] + 1 # j+1 instead of j since previous_row and current_row are one character longer
            deletions = current_row[j] + 1       # than s2
            substitutions = previous_row[j] + (c1 != c2)
            current_row.append(min(insertions, deletions, substitutions))
        previous_row = current_row

    return previous_row[-1]


def get_zuk_answer():
    G=nx.Graph()
    which_lang="Zh_Uy_Kz"
    # input_filename="share_ratio/Z_U_K.csv"
    # input_filename="partition_big/5000_ZUK_1217.csv"
    input_filename="partition_graph1210/Zh_Uy_Kz/Zh_Uy_Kz_subgraph_0.csv"


    output_distance0="answer/zuk_bigtrsns_distance0.txt"
    output_distance1="answer/zuk_bigtrsns_distance1.txt"
    output_distance2="answer/zuk_bigtrsns_distance2.txt"


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
    with open(output_distance0, "w") as file0:
            with open(output_distance1, "w") as file1:
                with open(output_distance2, "w") as file2:
                    for subgraph in graphs:
                        lang=nx.get_node_attributes(subgraph,'lang') # <-この処理遅い
                        pivot_connected = set()
                        pivot_share = set()
                        share_ratio=set()

                        pivot_connected_answer = set()
                        pivot_share_answer = set()
                        share_ratio_answer =set()
                        print ("hhhhhhhhhhhhhhhh" + str(subgraph_count) + "hhhhhhhhhhhhhhhhhhhhhh")
                        print(len(subgraph))
                        subgraph_count+=1

                        # print "*********************subgraph node数:"+str(len(subgraph))+"***************************"
                        if 6 < len(subgraph) :#and len(subgraph)<20: #!!! ノード数の制限
                            # ピボット数の制限
                            pivot_count=0
                            for node in subgraph.nodes():
                                if lang[node]=='En':
                                    pivot_count+=1

                            if pivot_count > 1:
                                pass_subgraph_count+=1
                                ja_neighbors_pivot = set()
                                de_neighbors_pivot = set()
                                for node_jade in subgraph.nodes():
                                    if lang[node_jade]=='Ja':
                                        ja_neighbors_pivot.add(node_jade)
                                        # pprint(node)
                                    elif lang[node_jade]=='De':
                                        de_neighbors_pivot.add(node_jade)

                                for i_js,ja in enumerate(ja_neighbors_pivot):
                                    ja=unicodedata.normalize('NFKC', ja).casefold()
                                    for i_de,de in enumerate(de_neighbors_pivot):
                                        de=unicodedata.normalize('NFKC', de).casefold()
                                        if ja[0]==de[0]:
                                            lev_distanve=levenshtein(ja,de)
                                            print(lev_distanve)
                                            if lev_distanve==0 and ja[0]==de[0]:
                                                print(lev_distanve)
                                                # pprint(levenshtein(unicodedata.normalize('NFKC', ja).casefold(),unicodedata.normalize('NFKC', de).casefold()))
                                                # put(ja)
                                                # sys.stdout.write(ja+","+de)
                                                # pprint(str.encode(ja))
                                                # sys.stdout.write(de+":")
                                                # pprint(str.encode(de))
                                                # pprint(unicodedata.normalize('NFC', ja))
                                                # file1.write(str(lev_distanve))
                                                # file0.write(ja+"("+str.encode(ja).decode(encoding='UTF-8')+")\n")
                                                # file0.write(de+"("+str.encode(de).decode(encoding='UTF-8')+")\n")
                                                file0.write(ja+","+de+"\n")

                                            if lev_distanve==1 and ja[0]==de[0]:
                                                print(lev_distanve)
                                                # file1.write(ja+"("+str.encode(ja).decode(encoding='UTF-8')+")\n")
                                                # file1.write(de+"("+str.encode(de).decode(encoding='UTF-8')+")\n")
                                                # print(ja)
                                                # pprint(str.encode(ja))
                                                # print(de)
                                                # pprint(str.encode(de))
                                                file1.write(ja+","+de+"\n")

                                            if lev_distanve==2 and ja[0]==de[0]:
                                                print(lev_distanve)
                                                file2.write(ja+","+de+"\n")
                                                # file2.write(ja+"("+str.encode(ja).decode(encoding='UTF-8')+")\n")
                                                # file2.write(de+"("+str.encode(de).decode(encoding='UTF-8')+")\n")


get_zuk_answer()
