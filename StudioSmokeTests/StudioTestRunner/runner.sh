#! /bin/sh

####
#Read values from StudioTestSetup.ini
#We use read_ini.sh script to enable read the ini file and get the key values in variables
####
. read_ini.sh
read_ini StudioTestSetup.ini

####
#Call the setup.sh which would setup the test environment based on values(version and other details) fetched from StudioTestSetup.ini
####
#bash setup.sh ${INI__APPC_CLI} ${INI__TI_SDK} ${INI__APPC_USER} ${INI__APPC_USER_PWD} ${INI__APPC_USER_ORG}

if [ $? == 0 ]
then
     echo "Initial Appc Setup Successful. Continue Test...."

     #sleep 5
     TestRunnerDir=/users/$(whoami)/RCPTTTestRunner
     rm -rf $TestRunnerDir
     mkdir -p $TestRunnerDir
     chmod ugo+rwx $TestRunnerDir
     # Set properties below
     runnerPath=./eclipse
     autPath=/Users/ssekhri/Documents/RCPTT_Workspace/AppceleratorStudio
     project=../../StudioSmokeTests
     #project=/Users/ssekhri/git/StudioAutomate/StudioSmokeTests/

     # properties below configure all intermediate and result files
     # to be put in "results" folder next to a project folder. If
     # that's ok, you can leave them as is

     testResults=$TestRunnerDir/results
     runnerWorkspace=$TestRunnerDir/RunnerWorkspace
     autWorkspace=$TestRunnerDir/RcpttTrialWorkspace
     autOut=$testResults/aut-out-
     junitReport=$testResults/results.xml
     htmlReport=$testResults/results.html

     rm -rf $testResults
     mkdir $testResults

     mkdir -p $autWorkspace/../Setupfile
     cp -f StudioTestSetup.ini $autWorkspace/../Setupfile
     
     java -jar $runnerPath/plugins/org.eclipse.equinox.launcher_1.3.200.v20160318-1642.jar \
          -application org.eclipse.rcptt.runner.headless \
          -data $runnerWorkspace \
          -aut $autPath \
          -autWsPrefix $autWorkspace \
          -autConsolePrefix $autOut \
          -htmlReport $htmlReport \
          -junitReport $junitReport \
          -import $project \
          -tests createAlloyWithoutServices.test \
          #-injection:site http://download.eclipse.org/releases/luna ;org.eclipse.jdt.feature.group; \
          

else
     (>&2 echo "Issues with Appc setup. Terminating the execution of automated tests.")
fi