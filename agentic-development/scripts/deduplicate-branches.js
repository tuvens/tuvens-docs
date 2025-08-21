#!/usr/bin/env node

/**
 * Branch Deduplication Script
 * 
 * Removes duplicate branch entries from active-branches.json,
 * keeping the most recent entry for each branch and converting
 * absolute paths to portable format.
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import os from 'os';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const TRACKING_DIR = path.join(__dirname, '..', 'branch-tracking');
const ACTIVE_BRANCHES_FILE = path.join(TRACKING_DIR, 'active-branches.json');

function makePathPortable(absolutePath) {
    if (!absolutePath) return absolutePath;
    const homeDir = os.homedir();
    return absolutePath.replace(homeDir, '~');
}

function loadJSON(filePath) {
    try {
        return JSON.parse(fs.readFileSync(filePath, 'utf8'));
    } catch (error) {
        console.error(`Error loading ${filePath}:`, error.message);
        return {};
    }
}

function saveJSON(filePath, data) {
    try {
        fs.writeFileSync(filePath, JSON.stringify(data, null, 2));
        console.log(`✅ Updated: ${path.basename(filePath)}`);
    } catch (error) {
        console.error(`Error saving ${filePath}:`, error.message);
    }
}

function deduplicateBranches() {
    console.log('🧹 Deduplicating branch tracking data...');
    
    const activeBranches = loadJSON(ACTIVE_BRANCHES_FILE);
    
    if (!activeBranches.branches) {
        console.log('No branches data found');
        return;
    }
    
    let totalDuplicatesRemoved = 0;
    let totalPathsFixed = 0;
    
    // Process each repository
    for (const [repo, branches] of Object.entries(activeBranches.branches)) {
        console.log(`\n📂 Processing repository: ${repo}`);
        
        if (!Array.isArray(branches)) continue;
        
        // Group branches by name
        const branchGroups = {};
        branches.forEach(branch => {
            if (!branchGroups[branch.name]) {
                branchGroups[branch.name] = [];
            }
            branchGroups[branch.name].push(branch);
        });
        
        // Keep only the most recent entry for each branch
        const dedupedBranches = [];
        let repoPathsFixed = 0;
        
        for (const [branchName, branchGroup] of Object.entries(branchGroups)) {
            if (branchGroup.length > 1) {
                console.log(`   🔍 Found ${branchGroup.length} duplicates of ${branchName}`);
                totalDuplicatesRemoved += branchGroup.length - 1;
                
                // Sort by lastActivity and keep the most recent
                branchGroup.sort((a, b) => new Date(b.lastActivity) - new Date(a.lastActivity));
            }
            
            // Take the most recent entry and fix paths
            const branch = branchGroup[0];
            
            // Convert absolute paths to portable format
            if (branch.worktree && branch.worktree.startsWith('/')) {
                const originalPath = branch.worktree;
                branch.worktree = makePathPortable(branch.worktree);
                if (branch.worktree !== originalPath) {
                    repoPathsFixed++;
                    totalPathsFixed++;
                    console.log(`   🔧 Fixed path: ${originalPath} → ${branch.worktree}`);
                }
            }
            
            dedupedBranches.push(branch);
        }
        
        console.log(`   ✅ ${repo}: ${branches.length} → ${dedupedBranches.length} branches`);
        if (repoPathsFixed > 0) {
            console.log(`   🔧 Fixed ${repoPathsFixed} hardcoded paths`);
        }
        
        activeBranches.branches[repo] = dedupedBranches;
    }
    
    // Update metadata
    activeBranches.lastUpdated = new Date().toISOString();
    activeBranches.generatedBy = 'Deduplication Script';
    
    // Save the cleaned data
    saveJSON(ACTIVE_BRANCHES_FILE, activeBranches);
    
    console.log(`\n📊 Summary:`);
    console.log(`   🗑️  Removed ${totalDuplicatesRemoved} duplicate entries`);
    console.log(`   🔧 Fixed ${totalPathsFixed} hardcoded paths`);
    console.log(`   ✅ Deduplication complete`);
}

// Run the deduplication
deduplicateBranches();