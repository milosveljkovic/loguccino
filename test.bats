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
    run ./jdk-8u312-ojdkbuild-linux-x64/bin/java -jar ./build/libs/loguccino.jar scan .

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