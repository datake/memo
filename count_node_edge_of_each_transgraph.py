# e*- encoding:utf-8 -*-
import networkx as nx
# import matplotlib.pyplot as plt
import pygraphviz as pgv
import csv
# import pydot
from pprint import pprint
# import pandas as pd
# import numpy as np

MINIMUN_NODES=4
MINIMUN_PIVOT=2

def count_edge():
    G=nx.Graph()
    language="DeToEn_EnToJa"
    is_all_transgraph=0 #全てのトランスグラフを対象にするか、マルダンのアプリケーションが対象とするものを対象にするか

    output_edge_folder="count_node_edge/edge/"
    if language=="Ind_Mnk_Zsm":
        input_filename="count_node_edge/Mnk_Ind_Zsm_new_arbi_original.csv"
    elif language=="JaToEn_JaToDe":
         input_filename="joined/JaToEn_JaToDe.csv"
    elif language=="JaToEn_EnToDe":
        input_filename="joined/JaToEn_EnToDe.csv"
    elif language=="JaToDe_DeToEn":
        input_filename="joined/JaToDe_DeToEn.csv"
    elif language=="Zh_Uy_Kz":
        input_filename="joined/Z_U_K.csv"
    elif language=="EnToJa_EnToDe":
        input_filename="joined/EnToJa_EnToDe.csv"
    elif language=="DeToEn_EnToJa":
        input_filename="joined/DeToEn_EnToJa.csv"

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


    with open(output_edge_folder+language+"_edge.csv", "w") as io_edge:
        for subgraph in graphs:
            lang=nx.get_node_attributes(subgraph,'lang') # <-この処理遅い

            pivot_count=0
            node_all = set()
            node_a = set()
            node_b = set()
            node_p = set()
            entoja_edge_num=0
            entode_edge_num=0
            all_edge_num=0

            if is_all_transgraph==1: #全てのトランスグラフ(ノード数等の指定しない)
                print("*********************subgraph number:"+str(subgraph_count)+"***************************")
                subgraph_count+=1
                print("*********************subgraph node数:"+str(len(subgraph))+"***************************")
                pprint(subgraph.nodes())
                for node in subgraph.nodes():
                    if lang[node]=='En':
                        pivot_count+=1

                if pivot_count > 0:
                    print("総エッジ数")
                    pprint(len(subgraph.edges()))
                    all_edge_num=len(subgraph.edges())
                    for node in subgraph.nodes():
                        if lang[node]=='En':
                            pprint(node)
                            for node_ja_de in subgraph.neighbors(node):
                                if lang[node_ja_de]=='Ja':
                                    entoja_edge_num+=1
                                elif lang[node_ja_de]=='De':
                                    entode_edge_num+=1

                    print("英語->日本語エッジ数")
                    pprint(entoja_edge_num)
                    print("英語->ドイツエッジ数")
                    pprint(entode_edge_num)
                    io_edge.write(str(all_edge_num)+","+str(entoja_edge_num)+","+str(entode_edge_num)+"\n")
                    print(str(all_edge_num)+","+str(entoja_edge_num)+","+str(entode_edge_num)+"\n")

            else: #マルダンのアプリケーションを通過する場合
                if MINIMUN_NODES <= len(subgraph):
                    print("*********************subgraph number:"+str(pass_subgraph_count)+"("+str(subgraph_count)+")***************************")
                    subgraph_count+=1
                    print("*********************subgraph node数:"+str(len(subgraph))+"***************************")
                    pprint(subgraph.nodes())
                    for node in subgraph.nodes():
                        pprint(node)
                        pprint(lang[node])
                        if lang[node]=='En':
                            pivot_count+=1

                    if pivot_count >= MINIMUN_PIVOT:
                        # en_edge_num=pivot_count
                        # print("英語ノード数")
                        # pprint(pivot_count)
                        pass_subgraph_count+=1
                        print("総エッジ数")
                        pprint(len(subgraph.edges()))
                        all_edge_num=len(subgraph.edges())
                        for node in subgraph.nodes():
                            if lang[node]=='En':
                                pprint(node)
                                for node_ja_de in subgraph.neighbors(node):
                                    if lang[node_ja_de]=='Ja':
                                        entoja_edge_num+=1
                                    elif lang[node_ja_de]=='De':
                                        entode_edge_num+=1

                        print("英語->日本語エッジ数")
                        pprint(entoja_edge_num)
                        print("英語->ドイツエッジ数")
                        pprint(entode_edge_num)
                        io_edge.write(str(all_edge_num)+","+str(entoja_edge_num)+","+str(entode_edge_num)+"\n")
                        print(str(all_edge_num)+","+str(entoja_edge_num)+","+str(entode_edge_num)+"\n")

def count_node():
    G=nx.Graph()
    language="DeToEn_EnToJa"
    is_all_transgraph=0

    output_node_folder="count_node_edge/node/"

    if language=="Ind_Mnk_Zsm":
        input_filename="count_node_edge/Mnk_Ind_Zsm_new_arbi_original.csv"
    elif language=="JaToEn_JaToDe":
         input_filename="joined/JaToEn_JaToDe.csv"
    elif language=="JaToEn_EnToDe":
        input_filename="share_ratio/JaToEn_EnToDe.csv"
    elif language=="JaToDe_DeToEn":
        input_filename="joined/JaToDe_DeToEn.csv"
    elif language=="Zh_Uy_Kz":
        input_filename="share_ratio/Z_U_K.csv"
    elif language=="EnToJa_EnToDe":
        input_filename="joined/EnToJa_EnToDe.csv"
    elif language=="DeToEn_EnToJa":
        input_filename="joined/DeToEn_EnToJa.csv"

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

    with open(output_node_folder+language+"node.csv", "w") as io_node:
        for subgraph in graphs:
            lang=nx.get_node_attributes(subgraph,'lang') # <-この処理遅い
            # if len(subgraph)<30000: #大きいトランスグラフをとばす場合はコメントアウト外す
            # ピボット数の制限
            pivot_count=0
            node_all = set()
            node_a = set()
            node_b = set()
            node_p = set()
            if is_all_transgraph==1:
                print("*********************subgraph number:"+str(pass_subgraph_count)+"("+str(subgraph_count)+")***************************")
                subgraph_count+=1
                print("*********************subgraph node数:"+str(len(subgraph))+"***************************")
                for node in subgraph.nodes():
                    if lang[node]=='En':
                        pivot_count+=1

                if pivot_count > 0:
                    pass_subgraph_count+=1
                    for node in subgraph.nodes():
                        node_all.add(node)
                        if lang[node]=='En':
                            node_p.add(node)

                        if lang[node]=='Ja':
                            node_a.add(node)

                        if lang[node]=='De':
                            node_b.add(node)

                    pprint(len(node_all))
                    pprint(len(node_a))
                    pprint(len(node_p))
                    pprint(len(node_b))
                    io_node.write(str(len(node_all))+","+str(len(node_a))+","+str(len(node_p))+","+str(len(node_b))+"\n")
            else:
                if MINIMUN_NODES <= len(subgraph): #!!! ノード数の制限
                    print("*********************subgraph number:"+str(pass_subgraph_count)+"("+str(subgraph_count)+")***************************")
                    subgraph_count+=1
                    print("*********************subgraph node数:"+str(len(subgraph))+"***************************")
                    for node in subgraph.nodes():
                        if lang[node]=='En':
                            pivot_count+=1
                    if pivot_count >= MINIMUN_PIVOT:
                        pass_subgraph_count+=1
                        for node in subgraph.nodes():
                            node_all.add(node)
                            if lang[node]=='En':
                                node_p.add(node)

                            if lang[node]=='Ja':
                                node_a.add(node)

                            if lang[node]=='De':
                                node_b.add(node)

                        pprint(len(node_all))
                        pprint(len(node_a))
                        pprint(len(node_p))
                        pprint(len(node_b))
                        io_node.write(str(len(node_all))+","+str(len(node_a))+","+str(len(node_p))+","+str(len(node_b))+"\n")

count_node()
count_edge()
