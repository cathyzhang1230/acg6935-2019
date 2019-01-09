

/*

Ying's question: what if I have a piece of text, or a path to a folder in my code (several times)
and instead of having that repeated, can I assign that to a variable and set it once
(that way, if it needs changing later, you only have to change the one assignment, not multiple times  

yes -- macro variables
*/

/* macro variable assignment */

%let myVariable = 15 ;
%let myVariable2 = 'something here';
%let myVariable3 = C:\files\projects\stuff\import;
%let myVariable4 = "something here double quotes"; 


/* usage -- refer to variable name with & preceeding*/

%put myVariable is &myVariable;
%put myVariable2 is &myVariable2;
%put myVariable3 is &myVariable3;
%put myVariable4 is &myVariable4;

%put What is myVariable plus 10: %eval(&myVariable + 10);

/* things to know -- double quotes vs single quotes */

%put 'using single quotes here &myVariable';
%put "using single quotes here &myVariable";
%put  using single quotes here &myVariable;

/* these are my variables */

%let myVarsWins = roa ceq size;
%let myVarsNotWins = BIGN LOSS LITIGATION;
%let allMyVars = &myVarsWins &myVarsNotWins;
%put &allMyVars;

/* coding --- winsore the myVarsWins, make tables allMyVars *.
 


