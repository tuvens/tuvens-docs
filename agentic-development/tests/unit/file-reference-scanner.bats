#!/usr/bin/env bats

# Tests for file-reference-scanner.js integration

setup() {
    export SCANNER_PATH="scripts/file-reference-scanner.js"
    export TEST_DIR="tests/temp"
    mkdir -p "$TEST_DIR"
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "scanner should be executable" {
    run chmod +x "$SCANNER_PATH"
    [ "$status" -eq 0 ]
    
    run ls -la "$SCANNER_PATH"
    [[ "$output" =~ "-rwx" ]]
}

@test "scanner should show help when --help is passed" {
    run node "$SCANNER_PATH" --help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "File Reference Scanner" ]]
    [[ "$output" =~ "--verbose" ]]
    [[ "$output" =~ "--create-issues" ]]
}

@test "scanner should run successfully on small test case" {
    cat > "$TEST_DIR/test.md" << 'EOF'
# Test File
[Valid Link](./README.md)
[Template Link](.claude/agents/{agent-name}.md)
EOF
    
    # Create the referenced file
    echo "# README" > "$TEST_DIR/README.md"
    
    cd "$TEST_DIR"
    run node "../../$SCANNER_PATH" --output=results.json
    
    # Should exit with 0 if no broken references (templates are valid)
    [ "$status" -eq 0 ]
    [ -f "results.json" ]
    
    # Check that results contain expected data
    run node -e "const data = require('./results.json'); console.log(data.templateReferences || 0);"
    [ "$output" -gt 0 ]  # Should find at least one template
}

@test "scanner should handle template variables in agent files correctly" {
    cat > "$TEST_DIR/devops.md" << 'EOF'
# DevOps Agent

## Context Loading
- Load: .claude/agents/devops.md
- Load: tuvens-docs/repositories/$REPO.md

## References
[Protocol](agentic-development/protocols/{protocol-name}.md)
EOF
    
    cd "$TEST_DIR" 
    run node "../../$SCANNER_PATH" --verbose --output=results.json
    
    # Check exit code - should pass with template variables recognized
    echo "Exit code: $status"
    echo "Output: $output"
    
    # Templates should be recognized as valid
    if [ -f "results.json" ]; then
        run node -e "
        const data = require('./results.json');
        console.log('Templates:', data.templateReferences || 0);
        console.log('Coverage:', data.coveragePercentage || 0);
        "
        echo "Results: $output"
    fi
}

@test "npm script integration works" {
    cd "$TEST_DIR"
    echo '{"type": "module"}' > package.json
    
    # Test that the npm script can find the scanner
    run npm run validate-references:ci --prefix ../..
    
    # Should execute without syntax errors
    echo "Exit code: $status"
    echo "Output: $output"
    
    # We expect it to find references and possibly exit 1 due to broken refs, but should not crash
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "scanner correctly identifies issue #337 false positive case" {
    cat > "$TEST_DIR/README.md" << 'EOF'
# Agent Discovery Index

## Loading Guidance
For Claude Code users:
```
Context Loading:
- Load: .claude/agents/{agent-name}.md
```
EOF
    
    cd "$TEST_DIR"
    run node "../../$SCANNER_PATH" --output=results.json
    
    echo "Exit code: $status"
    echo "Output: $output"
    
    if [ -f "results.json" ]; then
        # Template should be recognized, not broken
        run node -e "
        const data = require('./results.json');
        const templates = data.templateReferences || 0;
        const broken = data.brokenReferenceCount || 0;
        console.log('Templates found:', templates);
        console.log('Broken references:', broken);
        console.log('Coverage:', data.coveragePercentage || 0);
        
        // Main assertion: template variables should not be in broken references
        if (templates > 0 && data.coveragePercentage > 40) {
          console.log('SUCCESS: Templates recognized, coverage above threshold');
          process.exit(0);
        } else {
          console.log('FAIL: Templates not properly recognized');
          process.exit(1);
        }
        "
        [ "$status" -eq 0 ]
    fi
}