import numpy as np
import networkx as nx
import csv
from pprint import pprint
import pygraphviz as pgv
import matplotlib.pyplot as plt
from datetime import datetime
itr_count=0
# while itr_count<100:
#
#     itr=[]
#     weight = [1] * 10
#     # weight = [0.2531605027,0.320774498,0.1713213992,0.08402242406,0.04440092051,0.02575478045,0.0149637045,0.01003017924,0.006021465853,0.004034759747,0.002254648857,0.00171581481,0.001427267648,0.00125859926,0.0006137083256,0.000406779661,0.0002711864407,0.0003389830508,0.00006779661017,0.0002033898305,0.0002711864407,0.00006779661017,0.0004103184951,0,0,0,0.00006779661017,0.00006779661017,0,0]
#     weight = np.array(weight)
#     weight = weight/weight.sum()
#     for i in range(1,len(weight)+1):
#         itr.append(i)
#
#     node_a = np.random.choice(itr,p=weight)
#     node_b = np.random.choice(itr,p=weight)
#     print("node_a:"+str(node_a))
#     print("node_b:"+str(node_b))
#
#     itr=[]
#     weight_pivot = [1] * 10
#     # weight_pivot = [0,0.7768958627,0.1542562061,0.03509816081,0.01779913524,0.007474975851,0.002426599238,0.001526246866,0.002923928604,0.0002711864407,0.0006497320378,0.0001355932203,0,0.0001355932203,0,0.0001355932203,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
#     weight_pivot = np.array(weight_pivot)
#     weight_pivot = weight_pivot/weight_pivot.sum()
#     for i in range(1,len(weight_pivot)+1):
#         itr.append(i)
#     #重み付きランダム(ノード)
#     node_p = np.random.choice(itr,p=weight_pivot)
#
#     print("p:"+str(node_p))
#     itr=[]
#     weight_edge = [1] * 15
#     # weight_edge = [0.3783812933,0.2521690888,0.1451887865,0.06993896472,0.05019433731,0.02662702045,0.0161860435,0.01261468098,0.008239611842,0.006692367802,0.004658431193,0.003966963137,0.00233053026,0.001341815171,0.001616245302,0.001051670595,0.0009350355104,0.0009523962318,0.0002033898305,0.0002033898305,0.0002033898305,0.0002033898305,0.0005423728814,0.0002711864407,0,0.00006779661017,0.0002033898305,0.00006779661017,0,0.0002570694087,0.0001355932203,0.00006779661017,0,0.00006779661017]
#     weight_edge_a=np.array(weight_edge[node_a:-1])
#     weight_edge_b=np.array(weight_edge[node_b:-1])
#     weight_edge_a = weight_edge_a/weight_edge_a.sum()
#
#     weight_edge_b = weight_edge_b/weight_edge_b.sum()
#
#     itr_a=[]
#     itr_b=[]
#     # weight_edge = np.array(weight_edge)
#     # weight_edge = weight_edge/weight_edge.sum()
#     for i in range(node_a,len(weight_edge_a)+1):
#         itr_a.append(i)
#
#     for i in range(node_b,len(weight_edge_b)+1):
#         itr_b.append(i)
#
#
#     #重み付きランダム(ノード)
#     while True:
#         # edge_ap = np.random.choice(itr_a,p=weight_edge_a)
#         # edge_bp = np.random.choice(itr_b,p=weight_edge_b)
#         edge_ap=np.random.randint(np.max([node_a,node_p]), node_a+node_p)  # Integer from 1 to 10, endpoints included
#         edge_bp=np.random.randint(np.max([node_b,node_p]), node_b+node_p)  # Integer from 1 to 10, endpoints included
#         pprint(node_a)
#         pprint(node_b)
#         pprint(node_p)
#
#         print("edge_ap:"+str(edge_ap))
#         print("edge_bp:"+str(edge_bp))
#
#         condition=  edge_ap>= node_a and edge_bp>= node_b and edge_ap>= node_p and edge_bp>= node_p #ノード数とエッジの関係
#         condition = condition and (node_a+node_p)>=edge_ap and (node_b+node_p)>=edge_bp #これ以上はる枝がない
#
#         if condition:
#             break
#
# """
n=5
for node_a in range(1,n+1):
    for node_b in range(1,n+1):
        for node_p in range(1,5):
            # while True:
            for edge_ap in range(np.max([node_a,node_p]), node_a*node_p):
                for edge_bp in range(np.max([node_b,node_p]), node_b*node_p):

                    # edge_ap=np.random.randint(np.max([node_a,node_p]), node_a+node_p)  # Integer from 1 to 10, endpoints included
                    # edge_bp=np.random.randint(np.max([node_b,node_p]), node_b+node_p)  # Integer from 1 to 10, endpoints included
                    pprint(node_a)
                    pprint(node_b)
                    pprint(node_p)

                    print("edge_ap:"+str(edge_ap))
                    print("edge_bp:"+str(edge_bp))
                    #
                    # condition=  edge_ap>= node_a and edge_bp>= node_b and edge_ap>= node_p and edge_bp>= node_p #ノード数とエッジの関係
                    # condition = condition and (node_a+node_p)>=edge_ap and (node_b+node_p)>=edge_bp #これ以上はる枝がない
                    #
                    # if condition:
                    #     break


                    output_filename="generate_transgraph/"
                    condition=  edge_ap>= node_a and edge_bp>= node_b and edge_ap>= node_p and edge_bp>= node_p #ノード数とエッジの関係
                    condition = condition and (node_a*node_p)>=edge_ap and (node_b*node_p)>=edge_bp #これ以上はる枝がない
                    if condition:
                        G=nx.DiGraph()

                        # ピボット作成
                        for i in range(1,node_p+1):
                            G.add_node("p-"+str(i),lang='P',bipartite=2)
                            print("p-"+str(i))
                            if node_a>node_p:
                                G.add_edge("a-"+str(i),"p-"+str(i),is_edged=1)
                            if node_b>node_p:
                                G.add_edge("p-"+str(i),"b-"+str(i),is_edged=1)

                        #ノード作成
                        for i in range(1,node_a+1):
                            G.add_node("a-"+str(i),lang='A',has_edge_a=0,bipartite=0)
                            print("a-"+str(i))
                            # A-Pノード
                            if node_p>node_a:
                                G.add_edge("a-"+str(i),"p-"+str(i),is_edged=1)


                        for i in range(1,node_b+1):
                            G.add_node("b-"+str(i),lang='B',has_edge_b=0,bipartite=1)
                            print("b-"+str(i))
                            # B-Pノード
                            if node_p>node_b:
                                G.add_edge("p-"+str(i),"b-"+str(i),is_edged=1)
                        tmp=0
                        while True:
                            tmp+=1
                            #必ずはる
                            # if tmp<edge_ap:
                            #     for i in range(1,np.min([node_a,node_p])+1):
                            #         # tmp_a=np.random.random_integers(i)
                            #         # tmp_p=np.random.random_integers(i)
                            #         G.add_edge("a-"+str(i),"p-"+str(i),is_edged=1)
                            #         # print("p-a"+str(i))
                            #
                            #     for i in range(1,np.min([node_b,node_p])+1):
                            #
                            #         # tmp_b=np.random.random_integers(i)
                            #         # tmp_p=np.random.random_integers(i)
                            #         G.add_edge("p-"+str(i),"b-"+str(i),is_edged=1)
                            #         # print("p-b"+str(i))
                            #枝はる
                            # edge_ap=np.random.randint(np.max([node_a,node_p]), node_a+node_p)  # Integer from 1 to 10, endpoints included
                            # edge_bp=np.random.randint(np.max([node_b,node_p]), node_b+node_p)  # Integer from 1 to 10, endpoints included
                            tmp_a=np.random.random_integers(node_a)
                            tmp_p=np.random.random_integers(node_p)
                            tmp_b=np.random.random_integers(node_b)

                            #AとP
                            for i in range(np.min([node_a,node_p]),edge_ap+1):
                                tmp_a=np.random.random_integers(node_a)
                                tmp_p=np.random.random_integers(node_p)
                                tmp_b=np.random.random_integers(node_b)
                                if node_a > node_p: #P少ない
                                    G.add_edge("a-"+str(i),"p-"+str(tmp_p),is_edged=1)
                                else: #A少ない
                                    # for i in range(np.min([node_a,node_p])+1,edge_ap+1):
                                    G.add_edge("a-"+str(tmp_a),"p-"+str(i),is_edged=1)

                            #BとP
                            # if tmp<edge_bp:
                            for i in range(np.min([node_b,node_p]),edge_bp+1):
                                tmp_a=np.random.random_integers(node_a)
                                tmp_p=np.random.random_integers(node_p)
                                tmp_b=np.random.random_integers(node_b)
                                if node_b > node_p: #P少ない
                                    # for i in range(np.min([node_b,node_p])+1,edge_bp+1):
                                    G.add_edge("p-"+str(i),"b-"+str(node_b),is_edged=1)
                                else: #B少ない
                                    # for i in range(np.min([node_b,node_p])+1,edge_bp+1):
                                    G.add_edge("p-"+str(node_p),"b-"+str(i),is_edged=1)


                            # condition=nx.is_connected(G.to_undirected())
                            if tmp>20:
                                break

                            # if condition:
                            #     condition=condition and G.number_of_nodes()==(node_a+node_b+node_p) and G.number_of_edges()== (edge_ap+edge_bp)
                            #     if condition:
                            #         print("作成成功")
                            #         # break
                            #     else:
                            #         print("グラフ作成できず153")
                            #         # break
                            #
                            # else:
                            #     print("グラフ作成できず155")
                            #     continue


                            if nx.is_connected(G.to_undirected()) and G.number_of_nodes()==(node_a+node_b+node_p) and G.number_of_edges()== (edge_ap+edge_bp):
                                itr_count += 1
                                g_visualize = nx.to_agraph(G)
                                # g_visualize.draw(output_filename+"graph/"+str(node_a)+str(node_p)+str(node_b)+str(edge_ap)+str(edge_bp)+str(itr_count)+'.pdf',prog='dot')
                                g_visualize.draw(output_filename+"graph/"+str(node_a)+str(node_p)+str(node_b)+str(edge_ap)+str(edge_bp)+str(itr_count)+datetime(2014,1,2,3,4,5).strftime('%s')+'.pdf',prog='dot')
                            else:
                                print("グラフ作成できず163")
                                break

                            with open(output_filename+"csv/"+str(node_a)+str(node_p)+str(node_b)+str(edge_ap)+"-"+str(edge_bp)+str(itr_count)+".csv", "w") as file:
                                itr_count+=1
                                # lang=nx.get_node_attributes(G,'lang') # <-この処理遅い
                                file.write("test")
                    else:
                        print("グラフ作成できず")
                        continue
