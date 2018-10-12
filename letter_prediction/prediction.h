#include <vector>
#include <unordered_map>
#include <string>
#include <algorithm>
#include <unordered_set>
#include <iostream>
#include <sstream>
#include <fstream>

using namespace std;

//get valid charset from keyboard
string get_valid_char() {
	string valid_char;
	ifstream keyboard("keyboard.txt");
	//read the keyboard to vector, then calculate the scan time
	string line;
	if(keyboard.is_open()){
		while(getline(keyboard, line)) {
			valid_char += line;
		}
		keyboard.close();
	}	
	return valid_char;
}


//dump test files
string dump_test_file(vector<string>& text, string name) {
	ofstream out(name);
	string valid = get_valid_char();
	string ret = "";

	if(out.is_open()) {
		for(auto str : text) {
			istringstream iss(str);
			string word;
			while ( iss >> word ) {
				string new_word = "";
				for(auto c: word) 
					if(valid.find(c) != string::npos) 
						new_word += c;
				new_word += " ";
				ret += new_word;
			}
		}
		out << ret;
		out.close();
	}
	return ret;
} 

//dump result files
void dump_result_file(vector<string>& text, string name) {
	ofstream out(name);

	if(out.is_open()) {
		for(auto str : text) {
			out << str;
			out << "\n";
		}
		out.close();
	}
} 

/** 
count the word frequency of the training set
*/
void training_set_to_map(vector<string>& training_set, 
	unordered_map<string,int>& word_frequent){
	
	for(auto line : training_set) {
		istringstream iss(line);
		string word;
		while(iss >> word)
			word_frequent[word]++;
	}
}


/** 
split input file into training and test set
input: id is the line no. which go to test set
*/
void split_files(int id, 
	vector<string>& training_set, 
	vector<string>& test_set) {
	string line;
	ifstream input("brown.txt");

	int row = 0;
	if(input.is_open()) {
		while(getline(input,line)) {
			transform(line.begin(), line.end(), line.begin(), ::tolower);
			if(id == -1) {//special case: no test set, all training
				training_set.push_back(line);
				continue;
			}

			if(row%10 == id) test_set.push_back(line);
			else training_set.push_back(line);
			row = (row+1) % 10;
		}
		input.close();
	}
}

/** 
scan times of each char at keyboard
*/
void scan_keyboard(unordered_map<char,int>& char_map){
	string line;
	vector<string> dict;
	ifstream keyboard("keyboard.txt");
	//read the keyboard to vector, then calculate the scan time
	if(keyboard.is_open()){
		while(getline(keyboard, line)) {
			dict.push_back(line);
		}
		keyboard.close();
	}	
	//calculate the scan time and store into map
	for(int i=0; i<dict.size(); i++) {
		for(int j=0; j<dict[0].size(); j++) {
			char c = dict[i][j];
			//+3: due to additional dynamic row
			char_map[c] = i + j + 2;
//			cout << char_map[c] << " ";
		}		
//		cout<< endl;
	}
}

