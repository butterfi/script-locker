Edutopia test scripts

1. Install Selenium IDE 1.0.8 <http://release.seleniumhq.org/selenium-ide/1.0.8/> addon in Firefox
2. Check-out tests from
3. Each folder has its own test suite. Open Selenium IDE [Tools | Selenium IDE]
	anon_user: 
		Open the suite "Suite_anon_user". 
		Set the base URL at top of IDE as desired (ie: http://einstein.glef.org/)
		Select Play All in the IDE. 
	
	auth_user: 
		Open the suite "suite_auth_interaction"
		Set the base URL at top of IDE as desired (ie: http://einstein.glef.org/)
		Ensure the test "auth_RunFirst" is at the top (first to run).
		Select Play All in the IDE.
	
	NOTE: in the auth_RunFirst script there are test users setup (exist on einstein). 
	Change as needed/wanted in this script for use in this suite.

12/16/2010