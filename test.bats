#!/usr/bin/env bats

@test "Scenario 0 : Build loguccino." {
    run ./gradlew shadowDistTar shadowDistZip
    [ "$status" -eq 0 ]
}

@test "Scenario 1 : Check does /build/libs/loguccino* exists." {
    [ -f ./build/libs/loguccino* ]
}

# @test "Scenario 2 : Run scan and check csv." {
#     cp ./build/libs/loguccino*.jar ./build/libs/loguccino.jar
#     run java -jar ./build/libs/loguccino.jar scan .

#     [ "$status" -eq 0 ] 
#     mv loguccino-scan-* loguccino-scan.csv
#     run diff test.csv loguccino-scan.csv
    
#     [ "$status" -eq 0 ] # eq 0 - no difference, eq 1 - there is difference - test fail
# }

# @test "Scenario 3 : Run patch and check csv." {
#     run ./jdk-8u312-ojdkbuild-linux-x64/bin/java -jar ./build/libs/loguccino.jar patch ./loguccino-scan.csv

#     [ "$status" -eq 0 ]

#     run ./jdk-8u312-ojdkbuild-linux-x64/bin/java -jar ./build/libs/loguccino.jar scan .
#     mv loguccino-scan-* loguccino-patch.csv
#     [ "$status" -eq 0 ] 

#     run diff test-after-patch.csv loguccino-patch.csv
    
#     [ "$status" -eq 0 ] # eq 0 - no difference, eq 1 - there is difference - test fail
# }

@test "Scenario 4 : Create level 1 archives" {
    cp ./spring-log-test-project/build/libs/spring-*.jar ./build/libs/spring.jar
    cd build/libs/
    mkdir level1
    run zip level1/spring.zip spring.jar
    [ "$status" -eq 0 ]  
    run tar -czvf level1/spring.tgz spring.jar
    [ "$status" -eq 0 ]
    find level1/spring.tgz -print | cpio -ov > level1/spring.cpio
    [ "$status" -eq 0 ] 
    run ar r level1/spring.ar spring.jar
    [ "$status" -eq 0 ]
    # run arj a spring spring.jar
    # [ "$status" -eq 0 ]
    run tar -cvjSf level1/spring.tar.bz2 spring.jar
    [ "$status" -eq 0 ]
    run tar -cvf level1/spring.tar spring.jar
    [ "$status" -eq 0 ]
    rm spring.jar
}

@test "Scenario 5 : Scan level 1 archives" {
    cp ./build/libs/loguccino*.jar ./build/libs/loguccino.jar
    run java -jar ./build/libs/loguccino.jar scan ./build/libs/level1/

    [ "$status" -eq 0 ]
    mv loguccino-scan-* loguccino-scan.csv
    run diff level1-test.csv loguccino-scan.csv
    
    [ "$status" -eq 0 ] # eq 0 - no difference, eq 1 - there is difference - test fail
}

@test "Scenario 6 : Create level 2 archives" {
    cd build/libs/
    mkdir -p level2/zip level2/tgz level2/cpio level2/ar level2/tar.bz2 level2/tar
    for archive in level1/spring*; do
        extension=${archive#*.}
        run zip level2/$extension/spring.zip $archive
        [ "$status" -eq 0 ]  
        run tar -czvf level2/$extension/spring.tgz $archive
        [ "$status" -eq 0 ]
        find level2/$extension/spring.tgz -print | cpio -ov > level2/$extension/spring.cpio
        [ "$status" -eq 0 ] 
        run ar r level2/$extension/spring.ar $archive
        [ "$status" -eq 0 ]
        # run arj a spring $archive
        # [ "$status" -eq 0 ]
        run tar -cvjSf level2/$extension/spring.tar.bz2 $archive
        [ "$status" -eq 0 ]
        run tar -cvf level2/$extension/spring.tar $archive
        [ "$status" -eq 0 ]
    done
}

@test "Scenario 7 : Scan level 2 archives" {
    run java -jar ./build/libs/loguccino.jar scan ./build/libs/level2/
    [ "$status" -eq 0 ]

    mv loguccino-scan-* loguccino-scan2.csv

    run diff level2-test.csv loguccino-scan2.csv
    [ "$status" -eq 0 ] # eq 0 - no difference, eq 1 - there is difference - test fail
}