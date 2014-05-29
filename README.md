# APK Information Script

## Why?
To collect interesting information about your APK:

* APK size in bytes
* classes.dex size in bytes
* \# methods (useful for monitoring the magical 65k dex limit)
* \# classes

### Result (normal mode):

    user$ apk-stats.sh
    classes	methods	dex-bytes	apk-bytes	apk
    790	6451	9027848	1080992	SomeApp-production.apk
    760	6461	9027860	1081028	SomeApp-debug.apk
    700	6661	9027848	1081010	SomeApp-stage.apk

## Team City
To collect this information from a Team City job it supports TC's [system messages](http://confluence.jetbrains.com/display/TCD8/Custom+Chart) which you in turn can use to create nice charts for your project/job configuration.

The custom metrics are reported like this:

### Result (Team City mode):
	apk-stats.sh teamcity
	Team City system messages enabled!
	classes	methods	dex-bytes	apk-bytes	apk
    790	6451	9027848	1080992	SomeApp-production.apk
	##teamcity[buildStatisticValue key='classes-SomeApp-production.apk' value='790']
	##teamcity[buildStatisticValue key='methods-SomeApp-production.apk' value='6451']
	##teamcity[buildStatisticValue key='dex-size-SomeApp-production.apk' value='9027848']
	##teamcity[buildStatisticValue key='apk-size-SomeApp-production.apk' value='1080992']


Team City will automatically pick up these values and you'll see them under the job's _Parameters_ tab and under _Reported statistic values_. Click on this graph to see the trend.

### Custom chart setup
For a nice graph of these metrics on your project's Statistics tab change your Team City master's `.BuildServer/config/projects/:yourProject/pluginData/plugin-settings.xml` to something like this:

    <settings>
            <custom-graphs>
                    <graph title=".dex Information">
    			 		<properties>
    			    		<property name="axis.y.max" value="65536"/>
    						<property name="axis.y.min" value="0"/>
    						<property name="height" value="300"/>
    			  		</properties>
                    	<valueType key="methods-SomeApp-production.apk" title="Methods (Production)" buildTypeId="project_SomeJob"/>
                    	<valueType key="classes-SomeApp-production.apk" title="Classes (Production)" buildTypeId="project_SomeJob"/>
                    </graph>
                    <graph title="APP Size" format="size">
    			 		<properties>
    						<property name="height" value="300"/>
    			  		</properties>
                    	<valueType key="dex-size-SomeApp-production.apk" title=".dex (Production)" buildTypeId="project_SomeJob"/>
                    	<valueType key="apk-size-SomeApp-production.apk" title=".apk (Production)" buildTypeId="project_SomeJob"/>
                    </graph>
            </custom-graphs>
    </settings>