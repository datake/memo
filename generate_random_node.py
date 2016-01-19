import numpy as np
import networkx as nx
import csv
from pprint import pprint
import pygraphviz as pgv
import matplotlib.pyplot as plt
import os
from datetime import datetime
import time


def generate_transgraph(node_a,node_p,node_b,output_directory):
    itr_count=0
    n=10
    # output_directory="generate_transgraph/graph/"

    # while True:
    for edge_ap in range(np.max([node_a,node_p]), node_a*node_p):
        for edge_bp in range(np.max([node_b,node_p]), node_b*node_p):
            # print("a:"+str(node_a))
            # print("b:"+str(node_b))
            # print("p:"+str(node_p))
            #
            # print("edge_ap:"+str(edge_ap))
            # print("edge_bp:"+str(edge_bp))

            condition=  edge_ap>= node_a and edge_bp>= node_b and edge_ap>= node_p and edge_bp>= node_p #ノード数とエッジの関係
            condition = condition and (node_a*node_p)>=edge_ap and (node_b*node_p)>=edge_bp #これ以上はる枝がない
            if condition:


                tmp=0
                while True:
                    G=nx.DiGraph()

                    # ピボット作成
                    # for i in range(1,node_p+1):
                    for i in range(node_p):
                        G.add_node("p-"+str(i),lang='language_P',langP='1',langA='0',langB='0')
                        # print("p-"+str(i))


                    #ノード作成
                    # for i in range(1,node_a+1):
                    for i in range(node_a):
                        G.add_node("a-"+str(i),lang='language_A',langA='1',langB='0')
                        # print("a-"+str(i))


                    # for i in range(1,node_b+1):
                    for i in range(node_b):
                        G.add_node("b-"+str(i),lang='language_B',langB='1',langA='0')
                        print("b-"+str(i))

                    tmp+=1

                    #AとP
                    # for i in range(np.min([node_a,node_p]),edge_ap):
                    dict_ap={}
                    dict_bp={}
                    while len(dict_ap)<edge_ap:
                        # pprint(dict_ap)
                        tmp_a=np.random.randint(0,node_a)
                        tmp_p=np.random.randint(0,node_p)
                        # tmp_a=1
                        # tmp_p=1
                        G.add_edge("a-"+str(tmp_a),"p-"+str(tmp_p))
                        # print("a-"+str(tmp_a),"p-"+str(tmp_p))
                        dict_ap[str(tmp_a)+str(tmp_p)] = 1

                    #BとP
                    # for i in range(np.min([node_b,node_p]),edge_bp):
                    while len(dict_bp)<edge_bp:
                        # pprint(dict_bp)

                        tmp_p=np.random.randint(0,node_p)
                        tmp_b=np.random.randint(0,node_b)
                        G.add_edge("p-"+str(tmp_p),"b-"+str(tmp_b))
                        # print("b-"+str(tmp_b),"p-"+str(tmp_p))
                        dict_bp[str(tmp_p)+str(tmp_b)] = 1



                    # condition=nx.is_connected(G.to_undirected())
                    if tmp>50:
                        # print("グラフ作成できず163")

                        break

                    # 任意のピボットと必ずAとBはつながる
                    # A,B,Pの個数確認
                    count_connected_component=0
                    condition=0
                    has_edge_pa=0
                    has_edge_pb=0
                    output_node_a=0
                    output_node_b=0
                    output_node_p=0
                    dict_node_a={}
                    dict_node_b={}
                    dict_node_p={}
                    graphs = nx.connected_component_subgraphs(G.to_undirected())
                    is_not_connect_right=0
                    #
                    for subgraph in graphs:
                        count_connected_component+=1
                        if count_connected_component==1:
                            lang=nx.get_node_attributes(subgraph,'lang')
                            langP=nx.get_node_attributes(subgraph,'langP')
                            langA=nx.get_node_attributes(subgraph,'langA')
                            langB=nx.get_node_attributes(subgraph,'langB')

                            for node in subgraph.nodes():
                                # pprint("node")
                                # pprint(node)

                                print(lang[node])
                                if lang[node]=='language_P':
                                    # pprint(node)
                                    is_connect_right_a=0
                                    is_connect_right_b=0
                                    dict_node_p[node]=1
                                    for node_a_b in subgraph.neighbors(node):
                                        if lang[node_a_b]=='language_A':
                                            has_edge_pa=1
                                            dict_node_a[node_a_b]=1
                                            is_connect_right_a=1
                                        elif lang[node_a_b]=='language_B':
                                            has_edge_pb=1
                                            dict_node_b[node_a_b]=1
                                            is_connect_right_b=1

                                    #ピボットごとに必ずAもBもついているか確認
                                    if is_connect_right_a==1 and is_connect_right_b == 1:
                                        # is_not_connect_right=
                                        print("このピボットはAもBもついている")
                                    else:
                                        is_not_connect_right=1


                        else:
                            print("一つのトランスグラフになってない")
                            time.sleep(0.1)


                    if nx.is_connected(G.to_undirected()) and is_not_connect_right != 1:# and has_edge_pa ==1 and has_edge_pb == 1:#and G.number_of_nodes()==(node_a+node_b+node_p) and G.number_of_edges()== (edge_ap+edge_bp):
                        itr_count += 1
                        print("祝作成")
                        time.sleep(0.5)
                        itr_count+=1
                        g_visualize = nx.to_agraph(G)
                        output_new_dir=str(node_a)+"-"+str(node_p)+"-"+str(node_b)
                        if not os.path.exists(output_directory+output_new_dir):
                            os.makedirs(output_directory+output_new_dir)

                        # output_file=str(len(dict_node_a))+"-"+str(len(dict_node_p))+"-"+str(len(dict_node_b))+"-"+str(len(dict_ap))+"-"+str(len(dict_bp))+"-"+str(itr_count)+datetime(2014,1,2,3,4,5).strftime('%s')
                        output_file=str(len(dict_node_a))+"-"+str(len(dict_node_p))+"-"+str(len(dict_node_b))+"-"+str(len(dict_ap))+"-"+str(len(dict_bp))+"-"+str(itr_count)

                        g_visualize.draw(output_directory+output_new_dir+"/"+output_file+'.pdf',prog='dot')
                        # with open(output_directory+"csv/"+str(node_a)+str(node_p)+str(node_b)+str(edge_ap)+"-"+str(edge_bp)+str(itr_count)+".csv", "w") as file:
                            # itr_count+=1
                            # lang=nx.get_node_attributes(G,'lang') # <-この処理遅い
                            # file.write("test")
                        break


            else:
                print("グラフ作成できず")
                continue




def print_all():
    n=7
    output_directory="generate_transgraph/graph_all/"
    for node_a in range(1,n+1):
        for node_b in range(1,n+1):
            for node_p in range(1,4):
                generate_transgraph(node_a,node_p,node_b,output_directory)


def weighted_selected():#TODO:エッジの決め方もランダムにしないといけない
    itr_count=0
    output_directory="generate_transgraph/example_10/"
    while itr_count<100:
#
        itr=[]
        weight = [0.2531605027,0.320774498,0.1713213992,0.08402242406,0.04440092051,0.02575478045,0.0149637045,0.01003017924,0.006021465853,0.004034759747,0.002254648857,0.00171581481,0.001427267648,0.00125859926,0.0006137083256,0.000406779661,0.0002711864407,0.0003389830508,0.00006779661017,0.0002033898305,0.0002711864407,0.00006779661017,0.0004103184951,0,0,0,0.00006779661017,0.00006779661017,0,0]
        weight = np.array(weight)
        weight = weight/weight.sum()
        for i in range(1,len(weight)+1):
            itr.append(i)

        node_a = np.random.choice(itr,p=weight)
        node_b = np.random.choice(itr,p=weight)

        itr=[]
        weight_pivot = [0,0.7768958627,0.1542562061,0.03509816081,0.01779913524,0.007474975851,0.002426599238,0.001526246866,0.002923928604,0.0002711864407,0.0006497320378,0.0001355932203,0,0.0001355932203,0,0.0001355932203,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        weight_pivot = np.array(weight_pivot)
        weight_pivot = weight_pivot/weight_pivot.sum()
        for i in range(1,len(weight_pivot)+1):
            itr.append(i)
        #重み付きランダム(ノード)
        node_p = np.random.choice(itr,p=weight_pivot)
        # generate_transgraph(node_a,node_p,node_b,output_directory)
        print("node_a:"+str(node_a)+",node_b:"+str(node_b)+",node_p:"+str(node_p))
        itr_count+=1

print_all()
