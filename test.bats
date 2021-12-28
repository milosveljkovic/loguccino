#!/usr/bin/env bats

@test "Scenario 0 : Build loguccino." {
    run ./gradlew shadowDistTar shadowDistZip
    [ "$status" -eq 0 ]
}

@test "Scenario 1 : Check does /build/libs/loguccino* exists." {
    [ -f ./build/libs/loguccino* ]
}

@test "Scenario 2 : Run scan and check csv." {
    cp ./build/libs/loguccino*.jar ./build/libs/loguccino.jar
    run java -jar ./build/libs/loguccino.jar scan .

    [ "$status" -eq 0 ] 
    mv loguccino-scan-* loguccino-scan.csv
    run diff test.csv loguccino-scan.csv
    
    [ "$status" -eq 0 ] # eq 0 - no difference, eq 1 - there is difference - test fail
}

@test "Scenario 3 : Run patch and check csv." {
    run ./jdk-8u312-ojdkbuild-linux-x64/bin/java -jar ./build/libs/loguccino.jar patch ./loguccino-scan.csv

    [ "$status" -eq 0 ]

    run ./jdk-8u312-ojdkbuild-linux-x64/bin/java -jar ./build/libs/loguccino.jar scan .
    mv loguccino-scan-* loguccino-patch.csv
    [ "$status" -eq 0 ] 

    run diff test-after-patch.csv loguccino-patch.csv
    
    [ "$status" -eq 0 ] # eq 0 - no difference, eq 1 - there is difference - test fail
}

@test "Scenario 4 : Create level 1 archives" {
    cp ./spring-log-test-project/build/libs/spring-*.jar ./build/libs/spring.jar
    cd build/libs/
    run zip spring.zip spring.jar
    [ "$status" -eq 0 ]  
    run tar -czvf spring.tgz spring.jar
    [ "$status" -eq 0 ]
    find spring.tgz -print | cpio -ov > spring.cpio
    [ "$status" -eq 0 ] 
    run ar r spring.ar spring.jar
    [ "$status" -eq 0 ]
    run arj a spring spring.jar
    [ "$status" -eq 0 ]
    run tar -cvjSf spring.tar.bz2 spring.jar
    [ "$status" -eq 0 ]
    run tar -cvf spring.tar spring.jar
    [ "$status" -eq 0 ]
}
