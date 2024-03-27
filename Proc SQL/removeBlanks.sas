data RemoveBlanks;
	length y $ 10;
	string=" ABC D EF G H I ";
	x=TRIM(string);
	y=TRIM(string);
	TRIM='*'||TRIM(string)||'*';
	TRIMN='*'||TRIMN(string)||'*';
	STRIP='*'||STRIP(string)||'*';
	LEFT='*'||LEFT(string)||'*';
	RIGHT='*'||RIGHT(string)||'*';
	TRIM_LEFT='*'||TRIM(LEFT(string))||'*';
	TRIM_RIGHT='*'||TRIMN(RIGHT(string))||'*';
	COMPRESS='*'||COMPRESS(string)||'*';
	COMPBL='*'||COMPBL(string)||'*';
run;


DATA REMOVEBLANKS;
    LENGTH STRING $ 30 BLANK $ 30 ;
    STRING = " HELLO WORLD ";
    BLANK = "";
    TRIMMED_STRING = TRIM(STRING);
    TRIMMED_STRING2 = TRIM(BLANK);
    TRIMN = '*'||TRIM(STRING)||'*';
RUN;