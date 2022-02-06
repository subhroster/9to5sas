*Replace with your client and tenant ID;
* 1. UPDATE YOUR CLIENT ID;
%let client_id=YOUR CLIENT ID;
* 2. PASTE YOUR TENANT ID;
%let tenant_id=YOUR TENANT ID;
%let redirect_uri=https://login.microsoftonline.com/common/oauth2/nativeclient;
%let resource =https://graph.microsoft.com;

%* Temporary filename for request response data *;
filename resp TEMP;

%macro echofile(file);
	data _null_;
		infile &file;
		input;
		put _infile_;
	run;

%mend;

* 3. Run this line to build the authorization URL;
%let authorize_url=https://login.microsoftonline.com/&tenant_id./oauth2/authorize?client_id=&client_id.%nrstr(&response_type)=code%nrstr(&redirect_uri)=&redirect_uri.%nrstr(&resource)=&resource.;
options nosource;
%put Paste this URL into your web browser:;
%put -- START -------;
%put &authorize_url;
%put ---END ---------;
options source;
* 4. AFTER CLICKING 'TRUST IT', PASTE AUTH CODE FROM LOCALHOST URL ;
%let auth_code=;
*Get the Initial Refresh Token;
* 5. SUBMIT! REFRESH TOKEN WILL BE DISPLAYED IN LOG AND CAPTURED IN THE AUTHKEY0 DATA SET IN YOUR WORK LIBRARY ;
* (CALL MACRO BY RUNNING THIS): %TOKEN_INITIAL;

%macro TOKEN_INITIAL;
	%let auth_url="https://login.microsoftonline.com:443/&tenant_id./tokens/OAuth/2";
	%let redirect_uri=https://login.microsoftonline.com/common/oauth2/nativeclient;
	%let resource=https://graph.microsoft.com;

	proc http url="https://login.microsoft.com/&tenant_id./oauth2/token" 
			method="POST" in="%nrstr(&client_id)=&client_id.%nrstr(&code)=&auth_code.%nrstr(&redirect_uri)=&redirect_uri%nrstr(&grant_type)=authorization_code%nrstr(&resource)=&resource." 
			out=resp;
	run;

	%echofile(resp);
	%* Set up libname for JSON file output *;
	libname auth json fileref=resp;
	title 'Initial Token';

	proc print data=auth.root;
		title;

	data AUTHKEY0;
		set auth.root;
		sas_dt_Expires_on=put(dhms('01jan1970'd, 0, 0, expires_on + gmtoff()), 
			datetime22.3);
		call symputx('access_token', access_token, 'G');
		call symputx('refresh_token', refresh_token, 'G');

		/* convert epoch value to SAS datetime */
		call symputx('expires_on', (input(expires_on, best32.)+'01jan1970:00:00'dt), 
			'G');
	run;

	options nosource;
	%put -- START -------;
	%put &refresh_token;
	%put ---END ---------;
	options source;
%mend TOKEN_INITIAL;

* 5. AFTER YOU GET YOUR REFRESH TOKEN, PASTE IT HERE (AND REMOVE CARRIAGE RETURNS IF COPIED FROM LOG) ;
%let refresh_token=;

/*
Utility macro to redeem the refresh token and get a new access token for use in subsequent
calls to the OneDrive service.
*/
* 6. CALL THE REFRESH TOKEN IN YOUR JOB BY INCLUDING THIS FILE AND CALLING THIS MACRO: %TOKEN_REFRESH;
* 7. VIEW THE HTTP RESPONSE FROM SHAREPOINT AFTER EACH ACTION BY CALLING THIS MACRO: %echofile(resp);
****** REFRESH TOKEN;

%MACRO TOKEN_REFRESH;
	proc http url="https://login.microsoft.com/&tenant_id./oauth2/token" 
			method="POST" in="%nrstr(&client_id)=&client_id.%nrstr(&refresh_token=)&refresh_token%nrstr(&redirect_uri)=&redirect_uri.%nrstr(&grant_type)=refresh_token%nrstr(&resource)=&resource." 
			out=resp;
		%echofile(resp);
		libname auth json fileref=resp;

	proc datasets lib=auth;
	quit;

	data AUTHKEY0;
		set auth.root;
		sas_dt_Expires_on=put(dhms('01jan1970'd, 0, 0, expires_on + gmtoff()), 
			datetime22.3);
		call symputx('access_token', access_token, 'G');
		call symputx('refresh_token', refresh_token, 'G');

		/* convert epoch value to SAS datetime */
		call symputx('expires_on', (input(expires_on, best32.)+'01jan1970:00:00'dt), 
			'G');
	run;

	title 'Refresh Token';

	proc print;
		title;
	%mend TOKEN_REFRESH;