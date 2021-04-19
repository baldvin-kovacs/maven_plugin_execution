#!/bin/bash

rm -rf ./01-following-the-doc ./02-with-execution-id-as-default-cli

echo '# Reproduction of Maven not executing build-helper as expected'
echo ''
echo ''
echo 'This document is generated with the reproduce.sh script.'
echo ''
echo "- System: \`$(uname -a)\`"
echo '- Java:'
echo '```'
java -version 2>&1
echo '```'
echo '- Maven:'
echo '```'
mvn -v
echo '```'

function generate_quickstart {
  mvn archetype:generate \
	-B \
	-DarchetypeGroupId=org.apache.maven.archetypes \
	-DarchetypeArtifactId=maven-archetype-quickstart \
	-DarchetypeVersion=1.4 \
	-DgroupId=testgroupid \
	-DartifactId=testartifactid \
	-Dversion=1.0-SNAPSHOT \
	-Dpackage=testpackage >mvn-gen.out 2>mvn-gen.err || (
  		echo Generating the basic archetype failed.
		exit 1
	)
}

function run_tests {
	C="mvn compile"
	(cd testartifactid; $C) 2> compile.err > compile.out && echo "- $C: **SUCCESS**" || echo "- $C: **FAIL**"

	C="mvn build-helper:add-source compile"
	(cd testartifactid; $C) 2> build-helper+compile.err > build-helper+compile.out && \
		echo "- $C: **SUCCESS**" || echo "- $C: **FAIL**"
}

(
    	DIR=01-following-the-doc 
	echo ''
	echo '-----------------------------'
	echo "- DIR: $DIR"
	echo ''
	echo 'This testcase generates a quickstart, and then adds to the pom.xml'
	echo 'the build-helper-maven-plugin, in a configuration that is very'
	echo 'standard, for example suggested also in the Maven Cookbook:'
	echo ''
	echo '```'
        echo '<plugin>'
        echo '  <groupId>org.codehaus.mojo</groupId>'
        echo '  <artifactId>build-helper-maven-plugin</artifactId>'
        echo '  <version>3.2.0</version>'
        echo '  <executions>'
        echo '    <execution>'
        echo '      <id>add-source</id>'
        echo '      <phase>generate-sources</phase>'
        echo '      <goals>'
        echo '        <goal>add-source</goal>'
        echo '      </goals>'
        echo '      <configuration>'
        echo '        <sources>'
        echo '          <source>${project.build.directory}/something</source>'
        echo '        </sources>'
        echo '      </configuration>'
        echo '    </execution>'
        echo '  </executions>'
        echo '</plugin>'
	echo '```'
	echo ''
	echo 'To test this, the testcase also adds a trivial class to the target/'
	echo 'subdirectory'.
	echo ''
	echo 'While according to the cookbook, the compile should just work,'
	echo 'not only it does not, but we cannot even run the plugin manually:'
	echo ''
	mkdir $DIR 
	cd $DIR 
	generate_quickstart
	patch --quiet -p0 < ../testartifactid-01.patch
    	run_tests
)

(
	DIR=./02-with-execution-id-as-default-cli
	echo ''
	echo '-----------------------------'
	echo "- DIR: $DIR"
	echo ''
	echo 'This testcase is the same as the one above, except it changes the'
	echo 'execution id to default-cli. The compile target still does not work,'
	echo 'but now at least we can manually trigger the plugin to work:'
	echo ''
	mkdir $DIR
	cd $DIR 
	generate_quickstart
	patch --quiet -p0 < ../testartifactid-01.patch
	patch --quiet -p0 < ../testartifactid-02.patch
	run_tests
)
