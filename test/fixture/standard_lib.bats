#!/usr/bin/env bats

REPOSITORY_ROOT="$( realpath -Lm "$( dirname "$( git rev-parse --git-dir 2> /dev/null )" )" )"

load "${REPOSITORY_ROOT}/test/test_helper/bats-support/load"
load "${REPOSITORY_ROOT}/test/test_helper/bats-assert/load"

load "${REPOSITORY_ROOT}/dist/util/standard_lib"

# executable_exists

@test "executable_exists: should tell whenever a determined shell invocable exists" {
    run executable_exists "init"

    assert_output "1"
}

@test "executable_exists: should tell whenever a determined shell invocable does not exist" {
    run executable_exists "nonexistant_${RANDOM}"

    assert_output "0"
}

# relative_to

@test "relative_to: should function normally" {
    run relative_to "$HOME" "${HOME}/inner_directory"

    assert_output "inner_directory"
}

# reduce_path

@test "reduce_path: should function normally" {
    run reduce_path "/" "/home/${USER}/../../usr/bin"

    assert_output "usr/bin"
}

# repository_root

@test "repository_root: should function normally" {
    run repository_root

    assert_output "$REPOSITORY_ROOT"
}
