%{
#include "heading.h"
//global
int yyerror (char* s);
int yylex (void);
int tmpcount = 0;
int lblcount = 0;
int paramVal = 0;
bool param_open = false;
bool semanticError = false;
ofstream os;
const char* reserved[] = {"this_is_a_test","function","beginparams","endparams","beginlocals","endlocals","beginbody","integer","array",
						"of","if","then","endif","else","while","do","foreach","in","beginloop","endloop","continue",
						"read","write","true","false","semicolon","colon","comma","lparen","rparen","lsquare","rsquare",
						"assign","return"};
						
vector<string> reservedKey(reserved, reserved + 33); 
// structures
vector <string> idtypeVector; //identifier type vector, integer or array
vector <string> idVector; //identifier vector
vector <string> opVector; //operand vector
vector <string> fVector; //function vector
vector <string> pVector; //parameter vector
vector <string> statementVector; // statement vector
vector <vector <string> > forvectorVector; // for statement vector vector
vector <vector <string> > loopvectorVector; // loop statement vector vector
vector <vector <string> > ifvectorVector; // if statement vector vector
stack <string> rStack;
stack <string> pStack;
//functions
bool undeclaredVariable(string);
string generate1();
string generate2();
bool wasDeclared(string);
%}
%union{
int val;
string* op_val;
}
%start	program
%token	FUNCTION BEGINPARAMS ENDPARAMS BEGINLOCALS ENDLOCALS BEGINBODY ENDBODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO FOREACH IN BEGINLOOP ENDLOOP CONTINUE READ WRITE TRUE FALSE SEMICOLON COLON COMMA LPAREN RPAREN LSQUARE RSQUARE ASSIGN RETURN
%token <val> NUMBER
%token <op_val> IDENTIFIER
%left MULT DIV MOD ADD SUB 
%left LT LTE GT GTE EQ NEQ
%right NOT
%left AND OR
%right ASSIGN
%%
program: 	functions
			{
				os.close();
				bool mainBool = false;
				for(unsigned int i = 0; i < fVector.size(); ++i){
					if(fVector.at(i) == "main"){
						mainBool = true;
					}
				}
				if (!mainBool) {
					cerr << "Semantic error: did not define a main function" << endl;
					semanticError = true;
					os.open("test152.mil", ofstream::trunc);
					os.close();
				}
			}
	 	;
functions:	functions function
		|
		;
functionH: FUNCTION IDENTIFIER
		{
			fVector.push_back(*($2));
			cout << "func " << *($2) << endl;
		}
		
beginParams: BEGINPARAMS
			{ param_open = true;}
			;
endParams:	ENDPARAMS
			{ param_open = false;}
			;
function:	functionH SEMICOLON beginParams dec endParams BEGINLOCALS dec ENDLOCALS BEGINBODY statementHelper ENDBODY
			{
				int num_param = 0;
				int idVector_size = idVector.size();
				if (idVector_size != 0) {
					for(int i = 0; i < idVector_size; ++i) {
						if (idtypeVector.at(i) == "INTEGER") {
							cout<<". " << idVector.at(i) << endl;
							os << ". " << idVector.at(i) << endl;
						}
						else {
							cout <<".[] "<< idVector.at(i)<< ", " << idtypeVector.at(i) <<endl;
							os << ".[] " << idVector.at(i) << ", " << idtypeVector.at(i) << endl;
						}
					}
				}
				idVector.clear();
				idtypeVector.clear();
				while (!pVector.empty()) {
					string paramVecFront = pVector.front();
					cout << "= " << paramVecFront<< ", $" << num_param << endl;
					os << "= " << paramVecFront << ", $" << num_param << endl;
					pVector.erase(pVector.begin());
					num_param += 1;
				} 
				int statementVector_size = statementVector.size();
				if (statementVector_size != 0) {
					for (int i=0; i<statementVector_size; ++i) {
	                	cout<<statementVector.at(i)<<endl;
	                	os << statementVector.at(i) << endl;
					}
				}
	            cout << "endfunc" << endl;
	            os << "endfunc" << endl;
	            
	        	idVector.clear();
	            idtypeVector.clear();
	            statementVector.clear();
	            pVector.clear();
	            if (semanticError) {
	            	cout << "semanticError!" << endl;
	            	os.open("test152.mil", ofstream::trunc);
					os.close();
	            }
			}
		;  
dec:		declaration SEMICOLON dec
		|
		;
declaration:	decHelper1 COLON decHelper2 
				{
				}
		;
decHelper1: 	IDENTIFIER COMMA decHelper1 
			{
				string temp = "_"+ *($1);
				bool tempBool = false;
				extern int row;
				for(unsigned int i = 0; i < idVector.size(); ++i) {
					if(idVector.at(i) == temp) {
						cerr << "Semantic Error: symbol \"" << temp << "\" has already been declared on line" << row  << endl;
						tempBool = true;
						break;
					}
				} 
				if (tempBool) {
					semanticError = true;
					os.open("test152.mil", ofstream::trunc);
					os.close();
				}
				extern int row;
				bool reservedErr = false;
				for(unsigned int i = 0; i < reservedKey.size(); ++i){
					if(*($1) == reservedKey.at(i)){
						cerr << "Semantic error: used reserved word for variable on line" << row << endl;
						reservedErr = true;
					}
				}
				if (reservedErr) {
					semanticError = true;
					os.open("test152.mil", ofstream::trunc);
					os.close();
				}
				string int_type = "INTEGER";
				if (temp.size() != 0) {
					idVector.push_back(temp);
					idtypeVector.push_back(int_type);
				}
			}
		| IDENTIFIER 
			{
				string temp = "_" + *($1);
				bool tempBool = false;
				extern int row;
				for(unsigned int i = 0; i < idVector.size(); ++i) {
					if(idVector.at(i) == temp) {
						cerr << "Semantic Error: symbol \"" << temp << "\" has already been declared on line" << row  << endl;
						tempBool = true;
						break;
					}
				} 
				if (tempBool) {
					semanticError = true;
					os.open("test152.mil", ofstream::trunc);
					os.close();
				}
				bool reservedErr = false;
				for(unsigned int i = 0; i < reservedKey.size(); ++i){
					if(*($1) == reservedKey.at(i)){
						cerr << "Semantic error: using reserved keyword for variable on line" << row << endl;
						reservedErr = true;
					}
				}
				if (reservedErr) {
					semanticError = true;
					os.open("test152.mil", ofstream::trunc);
					os.close();
				}
				if (temp.size() != 0) {
					idVector.push_back(temp);
					if(param_open){
						pVector.push_back(temp);
					}
				}
			}
		;
decHelper2:	ARRAY LSQUARE NUMBER RSQUARE OF INTEGER 
			{
				stringstream num;
				num << $3;
				int i = ($3);
				bool tempArr = false;
				if(i <= 0){
					cerr << "Semantic error: declared array of size less than or equal to 0" << endl;
					tempArr = true;
				}
				if (tempArr) {
					semanticError = true;
				}
				idtypeVector.push_back(num.str());
			}
		| INTEGER
			{
				string int_type = "INTEGER";
				if (int_type.size() != 0) {
					idtypeVector.push_back(int_type);
				}
			}
		;
statement:	varStatement {}
		| ifStatement {}
		| whileStatement {}
		| doStatement {}
		| foreachStatement {}
		| readStatement {}
		| writeStatement {}
		| continueStatement {}
		| returnStatement {}
		;
varStatement:	IDENTIFIER ASSIGN expression 
			{
				string temp = "_" + *($1);
				if (undeclaredVariable(temp)) {
					semanticError = true;
				}
				string identifier_statement = "= " + temp + ", " + opVector.at(opVector.size() - 1);
				extern int row;
				for (int i = 0; i < idtypeVector.size(); ++i) {
					if (idVector.at(i) == temp) {
						if (idtypeVector.at(i) != "INTEGER") {
							semanticError = true;
							cerr << "Error line: " << row << ", used array without specifying index" << endl;
						}
					}
				}
				if (identifier_statement.size() != 0) {
					statementVector.push_back(identifier_statement);
				}
				if (opVector.size() != 0) {
					opVector.pop_back();
				}
			}
		|	IDENTIFIER LSQUARE expression RSQUARE ASSIGN expression 
			{
				string array_name = "_" + *($1);
				string array_source = opVector.at(opVector.size() - 1);
				
				if (opVector.size() != 0) {
					opVector.pop_back();
				}
				string array_index = opVector.at(opVector.size() - 1);
				if (opVector.size() != 0) {
					opVector.pop_back();
				}
				extern int row;
				for (int i = 0; i < idtypeVector.size(); ++i) {
					if (idVector.at(i) == array_name) {
						if (idtypeVector.at(i) == "INTEGER") {
							semanticError = true;						
							cerr << "Error line: " << row << ", specified index with used variable"<< endl;
						}
					}
				}
				string array_statement = "[]= " + array_name + ", " + array_index + ", " + array_source;
				if (array_statement.size() != 0) {
					statementVector.push_back(array_statement);
				}
			}
		;
ifStatement:	ifHelper statementHelper ENDIF 
			{
				string if_end = ": " + ifvectorVector.back().at(1);
				if (if_end.size() != 0) {
					statementVector.push_back(if_end);
				}
				if (ifvectorVector.size() != 0) {
					ifvectorVector.pop_back();
				}
			}
		|	elseifHelper statementHelper ENDIF
			{
				string if_end = ": " + ifvectorVector.back().at(2);
				if (if_end.size() != 0) {
					statementVector.push_back(if_end);
				}
				if (ifvectorVector.size() != 0) {
					ifvectorVector.pop_back();
				}
			}
		;
statementHelper:	statement SEMICOLON statementHelper {}
		| statement SEMICOLON {}
		;
		
elseifHelper:	ifHelper statementHelper ELSE
					{
						string end_if_statement = ":= " + ifvectorVector.back().at(2);
						if (end_if_statement.size() != 0) {
							statementVector.push_back(end_if_statement);
						}
						
						string else_if_declare_statement = ": " + ifvectorVector.back().at(1);
						if (else_if_declare_statement.size() != 0) {
							statementVector.push_back(else_if_declare_statement);
						}
					}
		;
ifHelper:	IF boolExpr THEN
				{
					string temp = generate2();
					string if_true = "if_condition_true_" + temp;
		            string if_false = "if_condition_false_" + temp;
		            string end_if = "end_if_"  + temp;
		            
		            vector<string> label_statements;
		            label_statements.push_back(if_true);
		            label_statements.push_back(if_false);
		            label_statements.push_back(end_if);
		            ifvectorVector.push_back(label_statements);
		            
		            string if_true_statement = "?:= " + if_true + ", " + opVector.back();
		            statementVector.push_back(if_true_statement); // adds if_true label to statement vector
		            if (opVector.size() != 0) {
		            	opVector.pop_back();
		            }
		            
		            string if_false_statement = ":= " + if_false;
		            statementVector.push_back(if_false_statement); // adds if_false label to statement vector
		            
		            string if_declare_statement = ": " + if_true;
		            statementVector.push_back(if_declare_statement);// adds if_declare statment to statement vector
				}
		;
whileStatement:	whileHelper1 statementHelper ENDLOOP 
			{
				string while_loop_end = ": " + loopvectorVector.back().at(2);
				string while_loop_label = ":= " + loopvectorVector.back().at(0);
				
				if (while_loop_label.size() != 0) {
					statementVector.push_back(while_loop_label);
				}
				if (while_loop_end.size() != 0) {
					statementVector.push_back(while_loop_end);
				}
				if (loopvectorVector.size() != 0) {
					loopvectorVector.pop_back();
				}
			}
		;
whileHelper1: whileHelper2 boolExpr BEGINLOOP
			{
				string while_in = "?:= " + loopvectorVector.back().at(1) + ", " +  opVector.back();
				string while_end = ":= " + loopvectorVector.back().at(2);
				string whileHelper1 = ": " + loopvectorVector.back().at(1);
				if (opVector.size() != 0) {
					opVector.pop_back();
				}
				if (while_in.size() != 0) {
					statementVector.push_back(while_in);
				}
				if (while_end.size() != 0) {
					statementVector.push_back(while_end);
				}
				if (whileHelper1.size() != 0) {
					statementVector.push_back(whileHelper1);
				}
			}	
		;
whileHelper2: WHILE
				{
					string temp = generate2();
					string cond_true = "conditional_true" + temp;
		            string cond_false = "conditional_false" + temp; 
		            string while_loop = "while_loop" + temp;
		            
		            vector<string> while_statements;
		            if (while_loop.size() != 0) {
		            	while_statements.push_back(while_loop);
		            }
		            if (cond_true.size() != 0) {
		            	while_statements.push_back(cond_true);
		            }
		            if (cond_false.size() != 0) {
		            	while_statements.push_back(cond_false);
		            }
		            loopvectorVector.push_back(while_statements);
		            string while_declare = ": " + while_loop;
		            if (while_declare.size() != 0) { 
		            	statementVector.push_back(while_declare);
		            }
				}
		;
doStatement: doHelper1 WHILE boolExpr 
			{
				string do_while_done = "?:= " + loopvectorVector.back().at(0) + ", " + opVector.back();
				statementVector.push_back(do_while_done);
				if (opVector.size() != 0) {
					opVector.pop_back();
				}
				if (loopvectorVector.size() != 0) {
					loopvectorVector.pop_back();
				}
			}
		;
		
		
doHelper1:	doHelper2 statementHelper ENDLOOP
			{
				string do_while_cond_check = ": " + loopvectorVector.back().at(1); 
				if (do_while_cond_check.size() != 0) {
					statementVector.push_back(do_while_cond_check);
				}
			}
	;
doHelper2:	DO BEGINLOOP
			{
				string temp = generate2();
				vector<string> do_while_statements;
				string doHelper2 = "doHelper2" + temp;
				string do_while_check = "do_while_check" + temp;
				if (doHelper2.size() != 0) {
					do_while_statements.push_back(doHelper2);
				}
				if (do_while_check.size() != 0) {
					do_while_statements.push_back(do_while_check);
				}
				
				loopvectorVector.push_back(do_while_statements);
				
				string do_while_declare = ": " + doHelper2;
				if (do_while_declare.size() != 0) {
					statementVector.push_back(do_while_declare);
				}
			}
	;
foreachStatement: foreachHelper1 statementHelper ENDLOOP
			{
				statementVector.push_back(":= " + forvectorVector.back().at(0));
				statementVector.push_back(": " + forvectorVector.back().at(2));
			}
		;
// ~~~~~~~~~~~~ NOT DONE ~~~~~~~~~~~~~~~~ //
foreachHelper1: foreachHelper2 forExpression BEGINLOOP //IDENTIFIER IN IDENTIFIER BEGINLOOP
			{
				statementVector.push_back("?:= " + forvectorVector.back().at(1) + ", " +  opVector.back());
				statementVector.push_back(":= " + forvectorVector.back().at(2));
				statementVector.push_back(": " + forvectorVector.back().at(1));
			}
		;
		
foreachHelper2: FOREACH
			{
				string temp = generate2();
				
	            string _false = "conditional_false" + temp; 
	            string _true = "conditional_true" + temp;
	            string _loop = "foreach_loop" + temp;
	            
	            vector<string> foreach_statements;
	            foreach_statements.push_back(_loop);
	            foreach_statements.push_back(_true);
	            foreach_statements.push_back(_false);
	            
	            statementVector.push_back( ": " + _loop);
	            forvectorVector.push_back(foreach_statements);
			}
		;
forExpression: IDENTIFIER IN IDENTIFIER
			{}
		
readStatement:	READ IDENTIFIER readHelper1 
			{
				string temp = "_" + *($2);
				if (undeclaredVariable(temp)) {
					semanticError = true;
				}
				rStack.push(".< " + temp);
				while(rStack.size() < 0 || rStack.size() > 0)
				{
					statementVector.push_back(rStack.top());
					if (!rStack.empty()) rStack.pop();
				}
			}
		|	READ IDENTIFIER LSQUARE expression RSQUARE readHelper1
			{
				string temp = generate1();
				idtypeVector.push_back("INTEGER");
				idVector.push_back(temp);
				rStack.push(".< " + temp);
				rStack.push("[]= _" + *($2) + ", " + opVector.at(opVector.size() - 1) + ", " + temp);
				if (!opVector.empty()) opVector.pop_back();
				
				while(rStack.size() < 0 || rStack.size() > 0)
				{
					statementVector.push_back(rStack.top());
					if (!rStack.empty()) rStack.pop();
				}
			}
		;
readHelper1:	COMMA IDENTIFIER readHelper1
			{
				string temp = "_" + *($2);
				if (undeclaredVariable(temp)) {
					semanticError = true;
				}
				rStack.push(".< " + temp);
			}
		|	COMMA IDENTIFIER LSQUARE expression RSQUARE readHelper1
			{
				string generated_temp = generate1();
				idtypeVector.push_back("INTEGER");
				idVector.push_back(generated_temp);
				rStack.push(".< " + generated_temp);
				rStack.push("[]= " + *($2) + ", " + opVector.back() + ", " + generated_temp);
				if (!opVector.empty()) opVector.pop_back();
			}
		| {}
		;
		
writeHelper1: COMMA varTerm writeHelper1
			{}
		|	{}
		;
writeStatement:	WRITE varTerm writeHelper1
			{
				while(opVector.size() < 0 || opVector.size() > 0) 
				{
					string start = opVector.at(0);
					statementVector.push_back(".> " + start);
	
					opVector.erase(opVector.begin());
				}
				if (opVector.size() != 0) opVector.clear();
			}
		;
continueStatement:	CONTINUE 
			{
				extern int row;
				
				if (loopvectorVector.size() == 0) {
					semanticError = true;
					cerr << "Semantic Error: used continue outside of loop" << row << endl;
					os.open("test152.mil", ofstream::trunc);
					os.close();
				}
				if(loopvectorVector.size() < 0 || loopvectorVector.size() > 0) 
				{
					if(loopvectorVector.back().at(0) != "d")
					{
						string not_continue_statement = ":= " + loopvectorVector.back().at(1);
						statementVector.push_back(not_continue_statement);
					}
					else
					{
						string continue_statement = ":= " + loopvectorVector.back().at(0);
						statementVector.push_back(continue_statement);
					}
				}
			}
		;
returnStatement:	RETURN expression 
			{
				statementVector.push_back("ret " + opVector.back());
				if (!opVector.empty()) opVector.pop_back();
			}
		;
boolExpr: relationandexprH
		| boolExpr OR relationandexprH
			{
				string temp = generate1();
				idtypeVector.push_back("INTEGER");
				idVector.push_back(temp);
				
				string operand1 = opVector.back();
				string operand2 = opVector.at(opVector.size()-2);
				
				statementVector.push_back("|| " + temp + ", " + operand2 + ", " + operand1);
				
				for (int i = 0; i < 2; i++) {
					if (!opVector.empty()) opVector.pop_back();
				}
				
				opVector.push_back(temp);
			}
relationandexprH: relationandExpr
			| relationandexprH AND relationandExpr
				{
					string temp = generate1();
					idtypeVector.push_back("INTEGER");
					idVector.push_back(temp);
					
					string operand1 = opVector.back();
					string operand2 = opVector.at(opVector.size()-2);
					
					statementVector.push_back("&& " + temp + ", " + operand2 + ", " + operand1);
					
					for (int i = 0; i < 2; i++) {
						opVector.pop_back();
					}
					
					opVector.push_back(temp);	
				}
relationandExpr:	relationExprHelper {}
			| NOT relationExprHelper 
			{
				string temp = generate1();
				idtypeVector.push_back("INTEGER");
				idVector.push_back(temp);
				string operand1 = opVector.at(opVector.size()-1);
				statementVector.push_back("! " + temp + ", " + operand1);
				
				if (!opVector.empty()) opVector.pop_back();
				
				opVector.push_back(temp);
			}
			;
relationExprHelper:	comp {}
			| TRUE 
				{
					string temp = generate1();
					idtypeVector.push_back("INTEGER");
					idVector.push_back(temp);
					statementVector.push_back("= " + temp + ", 1");
					opVector.push_back(temp);
				}
			| FALSE 
				{
					string temp = generate1();
					idtypeVector.push_back("INTEGER");
					idVector.push_back(temp);
					
					statementVector.push_back("= " + temp + ", 0");
					
					opVector.push_back(temp);
				}
			| LPAREN boolExpr RPAREN 
				{}
			;
comp:	expression EQ expression 
		{
				string temp = generate1();
				idtypeVector.push_back("INTEGER");
				idVector.push_back(temp);
				
				string operand1 = opVector.at(opVector.size()-1);
				string operand2 = opVector.at(opVector.size()-2);
				
				statementVector.push_back("== " + temp + ", " + operand2 + ", " + operand1);
				
				for (int i = 0; i < 2; i++) {
					opVector.pop_back();
				}
				
				opVector.push_back(temp);			
		}
		| expression NEQ expression 
		{
				string temp = generate1();
				idtypeVector.push_back("INTEGER");
				idVector.push_back(temp);
				
				string operand1 = opVector.at(opVector.size()-1);
				string operand2 = opVector.at(opVector.size()-2);
				
				
				statementVector.push_back("!= " + temp + ", " + operand2 + ", " + operand1);
				
				for (int i = 0; i < 2; i++) {
					opVector.pop_back();
				}
				
				opVector.push_back(temp);			
		}
		| expression LT expression 
		{
				string temp = generate1();
				idtypeVector.push_back("INTEGER");
				idVector.push_back(temp);
				
				string operand1 = opVector.at(opVector.size()-1);
				string operand2 = opVector.at(opVector.size()-2);
				
				statementVector.push_back("< " + temp + ", " + operand2 + ", " + operand1);
				
				for (int i = 0; i < 2; i++) {
					opVector.pop_back();
				}
				
				opVector.push_back(temp);			
		}
		| expression GT expression 
		{
				string temp = generate1();
				idVector.push_back(temp);
				idtypeVector.push_back("INTEGER");
				
				string operand1 = opVector.at(opVector.size()-1);
				string operand2 = opVector.at(opVector.size()-2);
				
				statementVector.push_back( "> "  + temp + ", " + operand2 + ", " + operand1);
				
				for (int i = 0; i < 2; i++) {
					opVector.pop_back();
				}
				
				opVector.push_back(temp);			
		}
		| expression LTE expression 
		{
				string temp = generate1();
				
				idtypeVector.push_back("INTEGER");
				idVector.push_back(temp);
				
				string operand1 = opVector.at(opVector.size()-1);
				string operand2 = opVector.at(opVector.size()-2);
				
				statementVector.push_back("<= " + temp + ", " + operand2 + ", " + operand1);
				
				for (int i = 0; i < 2; i++) {
					opVector.pop_back();
				}
				
				opVector.push_back(temp);			
		}
		| expression GTE expression 
		{
				string temp = generate1();
				idVector.push_back(temp);
				idtypeVector.push_back("INTEGER");
				
				string operand1 = opVector.at(opVector.size()-1);
				string operand2 = opVector.at(opVector.size()-2);
				
				
				statementVector.push_back(">= " + temp + ", " + operand2 + ", " + operand1);
				
				for (int i = 0; i < 2; i++) {
					opVector.pop_back();
				}
				
				opVector.push_back(temp);			
		}
		;
expression:	multiplicative_expr multExprH {}
		;
multExprH:	ADD multiplicative_expr multExprH 
			{
				string temp = generate1();
				idtypeVector.push_back("INTEGER");
				idVector.push_back(temp);
				
				string operand1 = opVector.at(opVector.size()-1);
				string operand2 = opVector.at(opVector.size()-2);
				
				statementVector.push_back("+ " + temp + ", " + operand2 + ", " + operand1);
				for (int i = 0; i < 2; i++) {
					opVector.pop_back();
				}
				
				opVector.push_back(temp);
			}
		| SUB multiplicative_expr multExprH 
			{
				string temp = generate1();
				idtypeVector.push_back("INTEGER");
				idVector.push_back(temp);
				
				string operand1 = opVector.at(opVector.size()-1);
				string operand2 = opVector.at(opVector.size()-2);
				
				statementVector.push_back("- " + temp + ", " + operand2 + ", " + operand1);
				
				for (int i = 0; i < 2; i++) {
					opVector.pop_back();
				}
				
				opVector.push_back(temp);
			}
		| 
			{}
		;
multiplicative_expr:	term termH 
				{}
			;
termH:	MULT term termH
			{
				string temp = generate1();
				idVector.push_back(temp);
				idtypeVector.push_back("INTEGER");
				
				string operand1 = opVector.at(opVector.size()-1);
				string operand2 = opVector.at(opVector.size()-2);
				
				statementVector.push_back("* " + temp + ", " + operand2 + ", " + operand1);
				
				for (int i = 0; i < 2; i++) {
					opVector.pop_back();
				}
				
				opVector.push_back(temp);
			}
		| DIV term termH
			{
				string temp = generate1();
				
				idtypeVector.push_back("INTEGER");
				idVector.push_back(temp);
				
				string operand1 = opVector.at(opVector.size()-1);
				string operand2 = opVector.at(opVector.size()-2);
	
				statementVector.push_back("/ " + temp + ", " + operand2 + ", " + operand1);
				
				for (int i = 0; i < 2; i++) {
					opVector.pop_back();
				}
				
				opVector.push_back(temp);
			}
		| MOD term termH
			{
				string temp = generate1();
				idtypeVector.push_back("INTEGER");
				idVector.push_back(temp);
				
				string operand1 = opVector.at(opVector.size()-1);
				string operand2 = opVector.at(opVector.size()-2);
				
				statementVector.push_back("% " + temp + ", " + operand2 + ", " + operand1);
				
				for (int i = 0; i < 2; i++) {
					opVector.pop_back();
				}
				opVector.push_back(temp);
			}
		| 
			{}
		;
term:	identifierTerm 
			{}
		| varTerm 
			{}
		| SUB varTerm
			{
				string temp = generate1();
				idtypeVector.push_back("INTEGER");
				string operand1 = opVector.at(opVector.size()-1);
				idVector.push_back(temp);
				
				string push_item = "- " + temp + ", 0, " + operand1; 
				statementVector.push_back(push_item);
				
				if (!opVector.empty()) opVector.pop_back();
				opVector.push_back(temp);
			}
		;
identifierTerm: IDENTIFIER LPAREN identifierH RPAREN 
				{
					while(pStack.empty() == false) 
					{
						statementVector.push_back("param " + pStack.top());
						pStack.pop();
					}
					extern int row;
					bool functionErr = true;
					string var 
					for(unsigned int i  = 0; i < fVector.size(); ++i)
					{
						if(fVector.at(i) == *($1))
						{
							cout << fVector.at(i) << "O.O" << endl;
							functionErr = false;
						}
					}
					if (functionErr) {
						cerr << "Line Error: " << row << ", function \"" << *($1) << "\" was not declared"<< endl;
					}
					string temp = generate1();
					idVector.push_back(temp);
					idtypeVector.push_back("INTEGER");
					
					statementVector.push_back("call " + *($1) + ", " + temp);
					opVector.push_back(temp);
				}
		;
identifierH: expression COMMA identifierH 
			{
				pStack.push(opVector.at(opVector.size() - 1));
				if (!opVector.empty()) opVector.pop_back();
			}
		|	expression 
			{
				pStack.push(opVector.at(opVector.size() - 1));
				if (!opVector.empty()) opVector.pop_back();
			}
varTerm: 	var 
			{
				string temp = generate1();
				idtypeVector.push_back("INTEGER");
				idVector.push_back(temp);
				
				string operand1 = opVector.at(opVector.size()-1);
				if (!opVector.empty()) opVector.pop_back();
				
				if(operand1.at(0) != '['){
					string push_item = "= " + temp + ", " + operand1;
					statementVector.push_back(push_item);
				}
				else {
					string push_item = "=[] " + temp + ", " + operand1.substr(2);
					statementVector.push_back(push_item);
				}
				opVector.push_back(temp);
			}
		| NUMBER
			{
				string temp = generate1();
				idVector.push_back(temp);
				idtypeVector.push_back("INTEGER");
				opVector.push_back(temp);
				
				ostringstream num;
				num.clear();
				num << $1;
				statementVector.push_back("= " + temp + ", " + num.str());
			}
		| LPAREN expression RPAREN
			{
				while(pStack.size() < 0 || pStack.size() > 0)
                {
                    statementVector.push_back("param " + pStack.top());
                }
			}
		;
var:		IDENTIFIER 
			{
				if (undeclaredVariable("_" + *($1))) {
					semanticError = true;
				}
				opVector.push_back("_" + *($1));
			}
		|	IDENTIFIER LSQUARE expression RSQUARE 
			{
				string operandLatest = opVector.at(-1 + opVector.size());
				opVector.pop_back();
				string temp = "_" + *($1);
				string opStatement = "[]" + temp + "," + operandLatest;
				opVector.push_back(opStatement);
			}
		;  
%%
int yyerror(string s)
{
  extern int row, column;
  extern char *yytext;		
  
  cerr << "Error at line: "<<row<<", column "<<column<<", Unexpected Symbol: \""<<yytext<<"\""<<endl;
  exit(0);
}
int yyerror(char *s)
{
  return yyerror(string(s));
}
// define functions here
string generate1(){
	//DONT TOUCH JACKIE
	ostringstream sstream;
	string empty = "";
	sstream.str(empty);
	sstream << tmpcount;
	string tempvar = "_tempvar_"+ sstream.str();
	++tmpcount;
	return tempvar;
}
string generate2(){
	//DONT TOUCH JACKIE
	ostringstream sstream;
	string empty = "";
	sstream.str(empty);
	sstream << lblcount;
	string labelvar = "_labelvar_"+ sstream.str();
	++lblcount;
	return labelvar;
}
bool wasDeclared(string var)
{
	return true;
}
bool undeclaredVariable(string s) {
	extern int row;
	for(unsigned int i = 0; i < idVector.size(); i++) {
		if (idVector.at(i) == s) {
			return false;
		}
	}
	cerr << "Error Line: " << row << ", used variable: " << s << " was not previously declared" << endl;
	return true;
}
