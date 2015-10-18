#include <iostream>
#include <string>
#include <fstream>
#include <stdlib.h>
#include <vector>
#include <map>
#include <sstream>
#include <algorithm>
#include <string.h>
#include <utility>

using namespace std;

int read_data();
struct Dataset{
	int id;
	string keyword;
	string translation_words;
};

int main(){

	read_data();

}

int read_data() {
	int i=1;
	string filename;
	vector<string> VS;
	//vector<string> ::iterator vecitr;
	vector <pair <string, vector<string> > > S_VS;
	//pair <string, vector<string> > ::iterator pairitr;
	string str;
	string line;
	string str1,str2,str3,str4,str5;
	string vals;
	string key;
	string val;
	int cinnumber;
	cout<<"select -> 1:Ja_En.csv"<<endl;
	cin>>cinnumber;
	if(cinnumber==1){
		filename="Ja_En.csv";
	}
	const char* filename_char=filename.c_str();

	//ifstreamでファイル読み込み
	cout << "reading file..." << endl;
	//ファイル入力用
	ifstream ifs(filename_char);
	//ファイル出力用(入力ファイル名にoutput_を追加したファイルに出力)
	char outputfilename_char[30] = "output_";
	strcat(outputfilename_char, filename_char);
	ofstream ofs(outputfilename_char);


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
					VS.push_back(val);
				}
			}
			//ofs<<"\"\n";
			//S_VS[key] = VS; //これだと順番がばらばらになる
			S_VS[i].push_back(make_pair(key,VS));
			cout<<key<<":";
			//cout<<VS[0]<<endl;



		}
		cout<<endl;
		VS.clear();
		i++;
	}

	// for(int p=0;p< S_VS.size();p++){
  //  	// firstには見出し語
	//   cout << S_VS[p].first;
  //   // secondには訳語のvector
	// 	for(int q=0;q<S_VS[p].second.size();q++){
	// 		cout << S_VS[p].second[q];
 // 		}
	// 	cout <<endl;
 // 	}

	return 0;
}
