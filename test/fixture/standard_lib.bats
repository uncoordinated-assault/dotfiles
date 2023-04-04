#!/usr/bin/env bats

load "$PWD/test/test_helper/bats-support/load"
load "$PWD/test/test_helper/bats-assert/load"

load "$PWD/dist/util/standard_lib"

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
