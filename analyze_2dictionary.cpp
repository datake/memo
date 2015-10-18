#include <iostream>
#include <string>
#include <fstream>
#include <stdlib.h>
#include <vector>
#include <map>
#include <sstream>
#include <algorithm>
#include <string.h>

using namespace std;

int read_data(map<string, vector<string> > &head_trans,map<string, vector<string> > &trans_head, ifstream &ifs);
int dump_data(map<string, vector<string> > map_S_VS);
int write_map_S_VS_csv(map<string, vector<string> > map_S_VS, char* outputfilename_char);

/*
* 例
* 日1->英1辞書と英2->日2辞書を入力にする
*
* 日1->英1がhead_trans,
* 英1->日1がtrans_head,
*
* 英2->日2がtrans_head_inverse,
* 日2->英2がhead_trans_inverse,
*/

int main(){

	string filename,filename2;


	vector<string> ::iterator vecitr;
	map<string, vector<string> > head_trans;
	map<string, vector<string> > head_trans_inverse;
	map<string, vector<string> > ::iterator mapitr;
	map<string, vector<string> > ::iterator mapitr2;
	map<string, vector<string> > ::iterator mapitr3;
	map<string, vector<string> > trans_head;
	map<string, vector<string> > trans_head_inverse;
	vector<string> VS_tmp;
	map<string, vector<string> > union_dict1;
	map<string, vector<string> > union_dict2;
	map<string, vector<string> > intersection_dict;
	string str;




	int cinnumber;
	cout<<"select -> 1:Ja<->En"<<endl;
	cout<<"select -> 2:En<->De"<<endl;
	cout<<"select -> 3:Ja<->De"<<endl;

	cin>>cinnumber;
	if(cinnumber==1){
		filename="Ja_En.csv";
		filename2="En_Ja.csv";
	}else if(cinnumber==2){
		filename="En_De.csv";
		filename2="De_En.csv";
	}else if(cinnumber==3){
		filename="Ja_De.csv";
		filename2="De_Ja.csv";
	}
	const char* filename_char=filename.c_str();
	const char* filename2_char=filename2.c_str();

	//ifstreamでファイル読み込み
	cout << "reading file..." << endl;
	//ファイル入力用
	char inputfilename_char[30] = "input/";
	strcat(inputfilename_char, filename_char);
	ifstream ifs(inputfilename_char);
	char inputfilename2_char[30] = "input/";
	strcat(inputfilename2_char, filename2_char);
	ifstream ifs2(inputfilename2_char);

	//見出し語と訳語のファイル出力用
	char union_char1[30] = "output/union1_";
	strcat(union_char1, filename_char);
	char union_char2[30] = "output/union2_";
	strcat(union_char2, filename_char);
	//訳語とその回数のファイル出力用
	char intersection_char[30] = "output/intersection_";
	strcat(intersection_char, filename_char);


	if(ifs.fail() ||ifs2.fail()) {
		cerr << "That file does not exist.\n";
		exit(0);
	}

	read_data(head_trans,trans_head, ifs);
	read_data(head_trans_inverse,trans_head_inverse, ifs2);

	//head_transとtrans_head_inverseのkeyを比較
	//例 日->英辞書の日本語と英->日辞書の日本語を比較

	//日->英辞書の日本語について走査
	for (mapitr = head_trans.begin(); mapitr != head_trans.end(); mapitr++){
		//mapitr->firstは日->英辞書の日本語にあたるstring
		//mapitr->secondは日->英辞書の英語にあたるvector<string>
		//日->英辞書の日本語が英->日辞書の日本語に存在するかどうか検索
		mapitr2 = trans_head_inverse.find(mapitr->first);
		if (mapitr2 == trans_head_inverse.end() ) {
			//もしその見出し語が英->日辞書の日本語にないならunion1に追加
				union_dict1[mapitr->first]=mapitr->second;

			} else {
				//もしその見出し語が英->日辞書の日本語にあるならintersection_dictに登録
				intersection_dict[mapitr->first]=mapitr->second;
			}
		}

		//上の逆の場合
		for (mapitr = trans_head_inverse.begin(); mapitr != trans_head_inverse.end(); mapitr++){
			mapitr2 = head_trans.find(mapitr->first);
			if (mapitr2 == head_trans.end() ) {
				//もしその見出し語がないならunion2に追加
					union_dict2[mapitr->first]=mapitr->second;
				} else {
					//もしその見出し語があるならintersection_dictに既に登録されているはずなので、
					//マークをいれてから追加するintersection_dictのvalueのvectorの末尾にmapitr->second(vector)を追加
					//mapitr->first->second.push_back();

					intersection_dict[mapitr->first].push_back("and");
					//VS_tmp.clear();
					//VS_tmp.push_back(mapitr->second);
					//VS_tmp.insert(VS_tmp.end(), mapitr->second.begin(), mapitr->second.end());
					//intersection_dict[mapitr->first].push_back(VS_tmp);
					intersection_dict[mapitr->first].insert(intersection_dict[mapitr->first].end(), mapitr->second.begin(), mapitr->second.end());
				}
			}


		//dump_data(head_trans);
		write_map_S_VS_csv(union_dict1, union_char1);
		write_map_S_VS_csv(union_dict2, union_char2);
		write_map_S_VS_csv(intersection_dict, intersection_char);

		return 0;
	}


	int read_data(map<string, vector<string> > &trans_head,map<string, vector<string> > &head_trans, ifstream &ifs){
		int i=1;
		vector<string> VS_tmp;
		vector<string> VS;
		string line;
		string key;
		string vals;
		string val;

		map<string, vector<string> > ::iterator mapitr2;
		while(getline(ifs, line)) {//一行ずつ取得
			stringstream ss(line);
			string tmp;
			getline(ss, key, ',');//keyのみ取り出し

			//ダブルクオート削除
			key.erase(remove( key.begin(), key.end(), '\"' ),key.end());

			//value
			while(getline(ss, vals, '"')) {//"区切りで繰り返し
			if(vals.size() != 0 && vals!=","){//空文字または,でないなら
				stringstream ss2(vals);
				while(getline(ss2, val, ',')) {
					VS.push_back(val);//訳語をvectorに積む
					mapitr2 = trans_head.find(val);
					if (mapitr2 == trans_head.end() ) {
						//もしその訳語が未登録なら追加
						std::cout << "not found:" <<val<< std::endl;
						VS_tmp.clear();
						VS_tmp.push_back(key);
						trans_head[val]=VS_tmp;
					} else {
						//もしその訳語がすでに登録されていたら対応する見出し語を追加
						mapitr2->second.push_back(key);
						cout<<"found translation word:"<<mapitr2->first<<",ex:"<<mapitr2->second.back()<<endl;
					}
				}
			}

			head_trans[key] = VS;
		}
		VS.clear();
		i++;
	}
}

int dump_data(map<string, vector<string> > map_S_VS){
	map<string, vector<string> > ::iterator mapitr;
	for (mapitr = map_S_VS.begin(); mapitr != map_S_VS.end(); mapitr++){
		// firstには見出し語が
		cout << mapitr->first ;
		// secondには複数の訳語が入ってる
		for(int j=0;j<mapitr->second.size();j++){
			cout << mapitr->second[j]<<",";
		}
		cout <<endl;
	}
	cout<<"number of headwords="<<map_S_VS.size()<<endl;
	return 0;
}
int write_map_S_VS_csv(map<string, vector<string> > map_S_VS, char* outputfilename_char){
	map<string, vector<string> > ::iterator mapitr;
	ofstream ofs(outputfilename_char);
	for (mapitr = map_S_VS.begin(); mapitr != map_S_VS.end(); mapitr++){
		// firstには見出し語が
		ofs << mapitr->first<<"," ;
		// secondには複数の訳語が入ってる
		for(int j=0;j<mapitr->second.size();j++){
			if(j==(mapitr->second.size()-1)){
				ofs << mapitr->second[j]<<"\n";
			}else{
				ofs << mapitr->second[j]<<",";
			}
		}
	}
	cout<<"finished wrote "<<outputfilename_char<<endl;
	cout<<"number of headwords="<<map_S_VS.size()<<endl;
	return 0;
}
