#!/usr/bin/env bats
# DEMONSTRATION TEST - Will intentionally fail to show auto-issue creation
# This file should be removed after demonstrating the system works

# Load test setup
load setup

@test "demo: intentional failure to test auto-issue system" {
    # This test will always fail to demonstrate the auto-issue creation
    echo "This is a demonstration of the auto-issue creation system"
    echo "When this test fails, it should create a GitHub issue automatically"
    
    # Intentional failure
    [ 1 -eq 2 ]  # This will always fail: 1 does not equal 2
}

@test "demo: another failure to show multiple test failures" {
    # Another intentional failure
    echo "Testing multiple failure scenarios"
    
    # This should also fail
    [[ "hello" == "goodbye" ]]  # This will fail
}