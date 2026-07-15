// The purpose of this file is to test computing the git hash
#include"githash_lib.h"
#include"githash_test/githash_test_exe_hash.h"
#include"githash_test/githash_test_lib_hash.h"
#include<stdio.h>

int main()
{
    printf("%s\n", GIT_HASH_HEAD);
    printf("%s\n", GIT_HASH_GITHASH_TEST_LIB);
    printf("%s\n", GIT_HASH_GITHASH_TEST_EXE);
    return 0;
}
