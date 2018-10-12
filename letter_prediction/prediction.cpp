#include "prediction.h"

//using namespace std;

//pick the highest frequent candidates
string pick_best_candidates(vector<pair<int,char>>& candidates, 
	int& scan_time) {
	string next_char = "";
	sort(candidates.begin(), candidates.end(), [](auto& a, auto& b){return a.first > b.first; });
	//reverse(candidates.begin(), candidates.end());
	for( int k = 0; k < scan_time-2 and k < candidates.size(); k++ )
		next_char += candidates[k].second;
	return next_char;
}
//predict the next char set, i is current position
string predict_next_char(string& word, 
	int& i, int& scan_time, 
	vector<unordered_map<string,int>>& ngrams,
	string& valid_char) {

	string next_char = "";
	vector<pair<int,char>> candidates;

	if(i == 0) {//first char of the word
		auto ngram = ngrams[1];//unigram
		for(auto it : ngram) {
			candidates.push_back({it.second, it.first[0]});
		}
		next_char = pick_best_candidates(candidates, scan_time);
	} 
	else {
		
		string pre = word.substr(0,i);

		int end = i+1;
		//check all the possible char and pick the best set
		for( int j = 0 ; j < valid_char.size(); j++) {
			string new_word = pre + valid_char[j];
			int total = 0;
			//int n = 6;
			for ( int n = 1; n < ngrams.size() and end-n >=0 ; n++ ) {
			//if (end - n >= 0) {
				string history = new_word.substr(end-n, n);
				int frequent = ngrams[n][ history ];
				total += frequent;
			//}
			}
			candidates.push_back({total, valid_char[j]});
		}
		next_char = pick_best_candidates(candidates, scan_time);
	}
	return next_char;
}
/** 
Input: ngrams, word_frequent
Output: prediction result, vector of string
*/
void prediction(vector<unordered_map<string,int>>& ngrams, 
	string& test_set, 
	unordered_map<char,int>& char_map, 
	vector<string>& prediction_result) {
	//10 fold cross-validation
	istringstream iss(test_set);
	string word;
	string valid_char = get_valid_char() ;

	while(iss >> word) {

		string next = "";
		for ( int i = 0 ; i < word.size(); i++ ) {
			char c = word[i];
			next = "";
			
			int scan_time = char_map[c];
			//predict next char based on previous input
			next = predict_next_char(word, i, scan_time, ngrams, valid_char);
			//string str; str.push_back(word[i]); //test purpose
			//prediction_result.push_back(str+"#"+to_string(scan_time)+"#"+next);
			prediction_result.push_back(next);
		}
		//string sp = " ";
		//prediction_result.push_back(sp+"#"+next);//handle the space !!!
		prediction_result.push_back("");//handle space following each word!!!
	}
	//}
}
//learn multiple grams!
//for every gram, check all the positions of the word
void ngram_learning(int n, 
	unordered_map<char,int>& char_map, 
	unordered_map<string,int>& word_frequent, 
	vector<unordered_map<string,int>>& ngrams ) {
	//be careful, ngrams starts from 1 not 0!
	for(auto it : word_frequent) {
		auto word = it.first;
		auto frequent = it.second;
		if(word.empty()) continue;
		//check all grams within this word
		for(int i = 0; i < word.size(); i++) {
			for(int j = 1; j+i <= word.size() and j <=n; j++ ) {
				ngrams[j][word.substr(i,j)] += frequent;	
			}
		}
	}
}

int main(){
	//get the each scan time of keyboard char
	unordered_map<char,int> char_map;
	scan_keyboard(char_map);
	//split input file to training and test set
	//here we need a for loop to get all 10 folds
	vector<vector<string>> result;
	for(int id = 0 ; id < 10; id++) {
		vector<string> training_set, test_set;
		split_files(id, training_set, test_set);

		//dump the test files
		string test_file = "test_" + to_string(id) + ".txt";
		auto test_set1 = dump_test_file(test_set, test_file);

		//read the training files to a map
		unordered_map<string,int> word_frequent;
		training_set_to_map(training_set, word_frequent);

		//learn multi-n-gram model
		//first try 1 to 6 grams 
		int n = 6;
		vector<unordered_map<string,int>> ngrams(n+1);
		ngram_learning(n, char_map, word_frequent, ngrams);

cout<< "begin a new fold ..." << endl;
		//make prediction
		vector<string> fold;
		prediction(ngrams, test_set1, char_map, fold);
cout<< "end a new fold ..." << endl;
		//cout << test_set1 << endl;
		//result.push_back(fold);

		//dump the result files
		string predict_file = "predict_result" + to_string(id) + ".txt";
		dump_result_file(fold, predict_file);
	}

	return 0;
}
