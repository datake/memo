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

int read_data();
int dump_data(map<string, vector<string> > map_S_VS);
int write_head_trans_csv(map<string, vector<string> > map_S_VS, char* outputfilename_char);
int write_trans_heads_csv(map<string, vector<string> > map_S_VS, char* outputfilename_char);

int main(){
	int i=1;
	string filename;
	vector<string> VS;
	vector<string> VS_tmp;
	vector<string> ::iterator vecitr;
	map<string, vector<string> > map_S_VS;//見出し語とそれに対応する訳語
	map<string, vector<string> > ::iterator mapitr;
	map<string, vector<string> > map_S_VS2;//訳語とそれに対応する見出し語
	map<string, vector<string> > ::iterator mapitr2;
	string str;
	string line;
	string str1,str2,str3,str4,str5;
	string vals;
	string key;
	string val;
	int cinnumber;
	cout<<"select -> 1:Ja_En.csv"<<endl;
	cout<<"select -> 2:En_Ja.csv"<<endl;
	cout<<"select -> 3:De_En.csv"<<endl;
	cout<<"select -> 4:En_De.csv"<<endl;
	cout<<"select -> 5:Ja_De.csv"<<endl;
	cout<<"select -> 6:De_Ja.csv"<<endl;
	cin>>cinnumber;
	if(cinnumber==1){
		filename="Ja_En.csv";
	}else if(cinnumber==2){
		filename="En_Ja.csv";
	}else if(cinnumber==3){
		filename="De_En.csv";
	}else if(cinnumber==4){
		filename="En_De.csv";
	}else if(cinnumber==5){
		filename="Ja_De.csv";
	}else if(cinnumber==6){
		filename="De_Ja.csv";
	}
	const char* filename_char=filename.c_str();

	//ifstreamでファイル読み込み
	cout << "reading file..." << endl;
	//ファイル入力用
	char inputfilename_char[30] = "input/";
	strcat(inputfilename_char, filename_char);
	ifstream ifs(inputfilename_char);
	//見出し語と訳語の儀ファイル出力用
	char outputfilename_char[30] = "output/output_";
	strcat(outputfilename_char, filename_char);
	//訳語とその回数のファイル出力用
	char output_trans_heads_char[30] = "output/trans_heads_";
	strcat(output_trans_heads_char, filename_char);


	if(ifs.fail()) {
		cerr << "That file does not exist.\n";
		exit(0);
	}


	/*
	dumpされたcsvデータは例えば
	"en_word_1","ja_word1,ja_word2,ja_word3"
	の形式になっている
	*/

	while(getline(ifs, line)) {//一行ずつ取得
		stringstream ss(line);
		string tmp;
		getline(ss, key, ',');//keyのみ取り出し

		//ダブルクオート削除
		key.erase(remove( key.begin(), key.end(), '\"' ),key.end());
		//cout<<"key:"<<key<<endl;
		//ofs<<key<<",\"";

		//value
		while(getline(ss, vals, '"')) {//"区切りで繰り返し
			if(vals.size() != 0 && vals!=","){//空文字または,でないなら
				stringstream ss2(vals);
				while(getline(ss2, val, ',')) {
					//cout << "val:"<< val << endl;
					//ofs<<val;
					VS.push_back(val);//訳語をvectorに積む

					mapitr2 = map_S_VS2.find(val);
					if (mapitr2 == map_S_VS2.end() ) {
						//もしその訳語が未登録なら追加
						std::cout << "not found:" <<val<< std::endl;
						VS_tmp.clear();
						VS_tmp.push_back(key);
						map_S_VS2[val]=VS_tmp;
					} else {
						//もしその訳語がすでに登録されていたら回数を+1
						mapitr2->second.push_back(key);
						cout<<"found translation word:"<<mapitr2->first<<",ex:"<<mapitr2->second.back()<<endl;
					}
				}
			}
			//ofs<<"\"\n";
			map_S_VS[key] = VS; //当然だがmapだともとの順番通りにはinsertされないこと注意


		}
		VS.clear();
		i++;
	}


	//訳語数(mapitr->second)を調べる
	for (mapitr = map_S_VS.begin(); mapitr != map_S_VS.end(); mapitr++){
	 // firstには見出し語が
		//cout<< "searching .. key:" <<mapitr->first;
		// secondには複数の訳語が入ってる
		for(int j=0;j<mapitr->second.size();j++){
			if(j==(mapitr->second.size()-1)){
				//ofs << mapitr->second[j]<<"\n";
			}else{
				//ofs << mapitr->second[j]<<",";
			}
		}
	}


	//dump_data(map_S_VS);
	write_head_trans_csv(map_S_VS, outputfilename_char);
	write_trans_heads_csv(map_S_VS2, output_trans_heads_char);

	return 0;
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
int write_head_trans_csv(map<string, vector<string> > map_S_VS, char* outputfilename_char){
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

int write_trans_heads_csv(map<string, vector<string> > map_S_VS, char* outputfilename_char){
	map<string, vector<string> > ::iterator mapitr;
	ofstream ofs(outputfilename_char);
	for (mapitr = map_S_VS.begin(); mapitr != map_S_VS.end(); mapitr++){
		// firstには訳語,secondには複数の訳語
		ofs << mapitr->first<<",";
		for(int i=0;i<mapitr->second.size();i++){

			if(i==(mapitr->second.size()-1)){
				ofs<< mapitr->second[i]<<"\n";
			}else{
				ofs<< mapitr->second[i]<<",";
			}
		}
	}
	cout<<"finished wrote "<<outputfilename_char<<endl;
	cout<<"number of headwords="<<map_S_VS.size()<<endl;
	return 0;
}
