# !/usr/bin/env bats

@test "Build loguccino." {
    cd ..
    run ./gradlew shadowDistTar shadowDistZip
    [ "$status" -eq 0 ]
}

@test "Check does /build/libs/loguccino* exist." {
    [ -f ../build/libs/loguccino* ]
}

@test "Create level 1 archives." {
    ls > filenames.txt
    cat filenames.txt
    echo "ASSDDDDDDDDDDDD"
    ls ./spring-log-test-project/build/libs/
    cp './spring-log-test-project/build/libs/spring-log-test-project-v3.0.0-1-g23d4aec.dirty.jar' ../build/libs/spring.jar
    cd ../build/libs/
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
    # run tar -cvjSf level1/spring.tar.bz2 spring.jar
    # [ "$status" -eq 0 ]
    run tar -cvf level1/spring.tar spring.jar
    [ "$status" -eq 0 ]
    rm spring.jar
}

@test "Create level 2 archives." {
    cd ../build/libs/
    mkdir -p level2/zip level2/tgz level2/cpio level2/ar level2/tar
    cd level1
    for archive in spring*; do
        extension=${archive#*.}
        run zip ../level2/$extension/spring.zip $archive
        [ "$status" -eq 0 ]  
        run tar -czvf ../level2/$extension/spring.tgz $archive
        [ "$status" -eq 0 ]
        find ../level2/$extension/spring.tgz -print | cpio -ov > ../level2/$extension/spring.cpio
        [ "$status" -eq 0 ] 
        run ar r ../level2/$extension/spring.ar $archive
        [ "$status" -eq 0 ]
        # run arj a spring $archive
        # [ "$status" -eq 0 ]
        # run tar -cvjSf ../level2/$extension/spring.tar.bz2 $archive
        # [ "$status" -eq 0 ]
        run tar -cvf ../level2/$extension/spring.tar $archive
        [ "$status" -eq 0 ]
    done
}

@test "Create level N archives." {
    cd ../build/libs/
    mkdir -p leveln
    cd level2/zip
 
    run tar -czvf ../../leveln/spring.tgz spring.zip
    [ "$status" -eq 0 ]

    cd ../../leveln

    find ./spring.tgz -print | cpio -ov > ./spring.cpio
    [ "$status" -eq 0 ]

    run zip ./spring.zip spring.cpio # zip/cpio/tgz/zip/zip
    [ "$status" -eq 0 ] 

    rm spring.tgz spring.cpio # remove all files other than .ar
}

@test "Scan level 1 archives." {
    cd ..
    cp ./build/libs/loguccino*.jar ./build/libs/loguccino.jar
    run java -jar ./build/libs/loguccino.jar scan ./build/libs/level1/

    [ "$status" -eq 0 ]
    mv loguccino-scan-* loguccino-scan.csv
    run diff ./e2e_tests/level1-test.csv loguccino-scan.csv
    
    [ "$status" -eq 0 ] # eq 0 - no difference, eq 1 - there is difference - test fail
}


@test "Scan level 2 archives." {
    cd ..
    run java -jar ./build/libs/loguccino.jar scan ./build/libs/level2/
    [ "$status" -eq 0 ]

    mv loguccino-scan-* loguccino-scan2.csv
    run diff ./e2e_tests/level2-test.csv loguccino-scan2.csv
    [ "$status" -eq 0 ] # eq 0 - no difference, eq 1 - there is difference - test fail
}

@test "Scan level N archives." {
    cd ..
    run java -jar ./build/libs/loguccino.jar scan ./build/libs/leveln
    [ "$status" -eq 0 ]

    mv loguccino-scan-* loguccino-scanN.csv
    run diff ./e2e_tests/levelN-test.csv loguccino-scanN.csv
    [ "$status" -eq 0 ] # eq 0 - no difference, eq 1 - there is difference - test fail
}

@test "Run patch on level1." {
    cd ..
    run java -jar ./build/libs/loguccino.jar patch ./loguccino-scan.csv
    [ "$status" -eq 0 ]

    run java -jar ./build/libs/loguccino.jar scan ./build/libs/level1/
    [ "$status" -eq 0 ]

    mv loguccino-scan-* loguccino-patched.csv

    run diff ./e2e_tests/level1-test-patched.csv loguccino-patched.csv
    [ "$status" -eq 0 ] # eq 0 - no difference, eq 1 - there is difference - test fail
}

@test "Run patch on level2." {
    cd ..
    run java -jar ./build/libs/loguccino.jar patch ./loguccino-scan2.csv
    [ "$status" -eq 0 ]

    run java -jar ./build/libs/loguccino.jar scan ./build/libs/level2/
    [ "$status" -eq 0 ] 

    mv loguccino-scan-* loguccino-patched2.csv

    run diff ./e2e_tests/level2-test-patched.csv loguccino-patched2.csv
    [ "$status" -eq 0 ] # eq 0 - no difference, eq 1 - there is difference - test fail
}

@test "Run patch on levelN." {
    cd ..
    run java -jar ./build/libs/loguccino.jar patch ./loguccino-scanN.csv
    [ "$status" -eq 0 ]

    run java -jar ./build/libs/loguccino.jar scan ./build/libs/leveln/
    [ "$status" -eq 0 ]

    mv loguccino-scan-* loguccino-patchedN.csv

    run diff ./e2e_tests/levelN-test-patched.csv loguccino-patchedN.csv
    [ "$status" -eq 0 ] # eq 0 - no difference, eq 1 - there is difference - test fail
}