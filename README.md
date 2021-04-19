# Reproduction of Maven not executing build-helper as expected


This document is generated with the reproduce.sh script.

- System: `Linux karacsonyfa 5.4.0-72-generic #80-Ubuntu SMP Mon Apr 12 17:35:00 UTC 2021 x86_64 x86_64 x86_64 GNU/Linux`
- Java:
```
openjdk version "14.0.2" 2020-07-14
OpenJDK Runtime Environment (build 14.0.2+12-Ubuntu-120.04)
OpenJDK 64-Bit Server VM (build 14.0.2+12-Ubuntu-120.04, mixed mode, sharing)
```
- Maven:
```
[1mApache Maven 3.6.3[m
Maven home: /usr/share/maven
Java version: 14.0.2, vendor: Private Build, runtime: /usr/lib/jvm/java-14-openjdk-amd64
Default locale: en_US, platform encoding: UTF-8
OS name: "linux", version: "5.4.0-72-generic", arch: "amd64", family: "unix"
```

-----------------------------
- DIR: 01-following-the-doc

This testcase generates a quickstart, and then adds to the pom.xml
the build-helper-maven-plugin, in a configuration that is very
standard, for example suggested also in the Maven Cookbook:

```
<plugin>
  <groupId>org.codehaus.mojo</groupId>
  <artifactId>build-helper-maven-plugin</artifactId>
  <version>3.2.0</version>
  <executions>
    <execution>
      <id>add-source</id>
      <phase>generate-sources</phase>
      <goals>
        <goal>add-source</goal>
      </goals>
      <configuration>
        <sources>
          <source>${project.build.directory}/something</source>
        </sources>
      </configuration>
    </execution>
  </executions>
</plugin>
```

To test this, the testcase also adds a trivial class to the target/
subdirectory.

While according to the cookbook, the compile should just work,
not only it does not, but we cannot even run the plugin manually:

- mvn compile: **FAIL**
- mvn build-helper:add-source compile: **FAIL**

-----------------------------
- DIR: ./02-with-execution-id-as-default-cli

This testcase is the same as the one above, except it changes the
execution id to default-cli. The compile target still does not work,
but now at least we can manually trigger the plugin to work:

- mvn compile: **FAIL**
- mvn build-helper:add-source compile: **SUCCESS**
