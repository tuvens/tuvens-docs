#!/usr/bin/env node

/**
 * Documentation Tree Generator
 * Replicates event-harvester auto-documentation patterns
 * Generates structured documentation tree for the project
 */

import fs from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Configuration
const CONFIG = {
    outputFile: 'agentic-development/docs/auto-generated/doc-tree.md',
    excludeDirs: [
        'node_modules',
        '.git',
        '.github',
        'dist',
        'build',
        'coverage',
        'logs'
    ],
    excludeFiles: [
        '.DS_Store',
        'Thumbs.db',
        '*.log',
        '*.tmp'
    ],
    maxDepth: 4,
    includeFileTypes: [
        '.md',
        '.json',
        '.js',
        '.ts',
        '.yml',
        '.yaml',
        '.sh'
    ]
};

// Utility functions
const formatSize = (bytes) => {
    if (bytes === 0) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
};

const getFileIcon = (fileName) => {
    const ext = path.extname(fileName).toLowerCase();
    const iconMap = {
        '.md': '📄',
        '.json': '🔧',
        '.js': '⚡',
        '.ts': '💙',
        '.yml': '⚙️',
        '.yaml': '⚙️',
        '.sh': '🔨',
        '.py': '🐍',
        '.php': '🐘',
        '.html': '🌐',
        '.css': '🎨',
        '.scss': '💅',
        '.vue': '💚',
        '.svelte': '🧡',
        '.react': '⚛️'
    };
    return iconMap[ext] || '📄';
};

const shouldIncludeFile = (fileName) => {
    const ext = path.extname(fileName).toLowerCase();
    if (!CONFIG.includeFileTypes.includes(ext)) return false;
    
    return !CONFIG.excludeFiles.some(pattern => {
        if (pattern.includes('*')) {
            const regex = new RegExp(pattern.replace(/\*/g, '.*'));
            return regex.test(fileName);
        }
        return fileName === pattern;
    });
};

const shouldIncludeDir = (dirName) => {
    return !CONFIG.excludeDirs.includes(dirName) && !dirName.startsWith('.');
};

// Tree generation functions
const generateFileEntry = async (filePath, basePath = '') => {
    try {
        const stats = await fs.stat(filePath);
        const relativePath = path.relative(basePath, filePath);
        const fileName = path.basename(filePath);
        const icon = getFileIcon(fileName);
        const size = formatSize(stats.size);
        const modified = stats.mtime.toISOString().split('T')[0];
        
        return {
            name: fileName,
            path: relativePath,
            icon,
            size,
            modified,
            isFile: true
        };
    } catch (error) {
        console.warn(`Warning: Could not stat file ${filePath}: ${error.message}`);
        return null;
    }
};

const generateDirectoryTree = async (dirPath, basePath = '', depth = 0) => {
    if (depth > CONFIG.maxDepth) return null;
    
    try {
        const entries = await fs.readdir(dirPath);
        const dirName = path.basename(dirPath);
        
        if (!shouldIncludeDir(dirName) && depth > 0) return null;
        
        const tree = {
            name: dirName || 'root',
            path: path.relative(basePath, dirPath) || '.',
            isDirectory: true,
            children: []
        };
        
        // Sort entries - directories first, then files
        const sortedEntries = [];
        for (const entry of entries) {
            const fullPath = path.join(dirPath, entry);
            try {
                const stats = await fs.stat(fullPath);
                sortedEntries.push({
                    name: entry,
                    path: fullPath,
                    isDirectory: stats.isDirectory()
                });
            } catch (error) {
                // Skip entries we can't access
                continue;
            }
        }
        
        sortedEntries.sort((a, b) => {
            if (a.isDirectory !== b.isDirectory) {
                return a.isDirectory ? -1 : 1;
            }
            return a.name.localeCompare(b.name);
        });
        
        // Process entries
        for (const entry of sortedEntries) {
            if (entry.isDirectory) {
                const subTree = await generateDirectoryTree(entry.path, basePath, depth + 1);
                if (subTree) {
                    tree.children.push(subTree);
                }
            } else if (shouldIncludeFile(entry.name)) {
                const fileEntry = await generateFileEntry(entry.path, basePath);
                if (fileEntry) {
                    tree.children.push(fileEntry);
                }
            }
        }
        
        return tree.children.length > 0 ? tree : null;
    } catch (error) {
        console.warn(`Warning: Could not read directory ${dirPath}: ${error.message}`);
        return null;
    }
};

// Markdown generation functions
const generateMarkdownTree = (tree, prefix = '', isLast = true) => {
    if (!tree) return '';
    
    let result = '';
    const connector = isLast ? '└── ' : '├── ';
    const icon = tree.isDirectory ? '📁' : tree.icon;
    
    result += `${prefix}${connector}${icon} ${tree.name}`;
    
    if (tree.isFile) {
        result += ` (${tree.size}, ${tree.modified})`;
    }
    
    result += '\n';
    
    if (tree.children && tree.children.length > 0) {
        const childPrefix = prefix + (isLast ? '    ' : '│   ');
        
        tree.children.forEach((child, index) => {
            const childIsLast = index === tree.children.length - 1;
            result += generateMarkdownTree(child, childPrefix, childIsLast);
        });
    }
    
    return result;
};

const generateSummaryStats = (tree) => {
    const stats = { directories: 0, files: 0, totalSize: 0 };
    
    const traverse = (node) => {
        if (node.isDirectory) {
            stats.directories++;
        } else {
            stats.files++;
            // Convert size string back to bytes for total calculation
            const sizeStr = node.size.split(' ')[0];
            const unit = node.size.split(' ')[1];
            let bytes = parseFloat(sizeStr);
            
            switch (unit) {
                case 'KB': bytes *= 1024; break;
                case 'MB': bytes *= 1024 * 1024; break;
                case 'GB': bytes *= 1024 * 1024 * 1024; break;
            }
            
            stats.totalSize += bytes;
        }
        
        if (node.children) {
            node.children.forEach(traverse);
        }
    };
    
    traverse(tree);
    return stats;
};

const generateDocumentationTree = async () => {
    try {
        console.log('🌳 Generating documentation tree...');
        
        const projectRoot = process.cwd();
        const tree = await generateDirectoryTree(projectRoot, projectRoot);
        
        if (!tree) {
            throw new Error('Failed to generate directory tree');
        }
        
        const stats = generateSummaryStats(tree);
        const timestamp = new Date().toISOString();
        
        const markdownContent = `# Project Documentation Tree

> Auto-generated documentation tree for Tuvens project infrastructure
> 
> **Generated:** ${timestamp}
> **Generator:** docs-tree-generator v1.0.0

## Project Statistics

- 📁 **Directories:** ${stats.directories}
- 📄 **Files:** ${stats.files}  
- 💾 **Total Size:** ${formatSize(stats.totalSize)}
- 🕐 **Last Updated:** ${new Date().toLocaleString()}

## Directory Structure

\`\`\`
${generateMarkdownTree(tree)}
\`\`\`

## File Type Distribution

The project includes the following file types:
- **Markdown (.md):** Documentation and guides
- **JSON (.json):** Configuration and data files
- **JavaScript (.js):** Node.js scripts and utilities
- **YAML (.yml/.yaml):** GitHub Actions and configuration
- **Shell (.sh):** Build and automation scripts

## Key Directories

- **📁 agentic-development/**: Agent coordination and workflow management
- **📁 scripts/**: Build tools, validation scripts, and automation
- **📁 .github/workflows/**: CI/CD workflows and automation
- **📁 docs/**: Project documentation and guides

## Maintenance Notes

This tree is automatically updated when:
- Running \`npm run generate-docs\`
- During CI/CD pipeline execution
- Manual invocation of the doc-tree generator

---

*Generated by Tuvens Documentation System*
*Last scan: ${timestamp}*
`;

        // Ensure output directory exists
        const outputDir = path.dirname(CONFIG.outputFile);
        await fs.mkdir(outputDir, { recursive: true });
        
        // Write the documentation tree
        await fs.writeFile(CONFIG.outputFile, markdownContent, 'utf8');
        
        console.log(`✅ Documentation tree generated successfully!`);
        console.log(`📄 Output: ${CONFIG.outputFile}`);
        console.log(`📊 Stats: ${stats.directories} directories, ${stats.files} files`);
        console.log(`💾 Size: ${formatSize(stats.totalSize)}`);
        
        return true;
        
    } catch (error) {
        console.error('❌ Error generating documentation tree:', error.message);
        process.exit(1);
    }
};

// CLI handling
const printHelp = () => {
    console.log(`
Documentation Tree Generator

Usage: node scripts/generate-doc-tree.js [options]

Options:
  --help, -h     Show this help message
  --output, -o   Specify output file (default: ${CONFIG.outputFile})
  --depth, -d    Maximum directory depth (default: ${CONFIG.maxDepth})
  
Examples:
  node scripts/generate-doc-tree.js
  node scripts/generate-doc-tree.js --output docs/structure.md
  node scripts/generate-doc-tree.js --depth 3

This tool generates a comprehensive documentation tree showing:
- Project directory structure
- File sizes and modification dates
- Summary statistics
- Key directory descriptions
`);
};

// Main execution
if (process.argv.includes('--help') || process.argv.includes('-h')) {
    printHelp();
    process.exit(0);
}

// Parse command line arguments
const outputIndex = process.argv.findIndex(arg => arg === '--output' || arg === '-o');
if (outputIndex !== -1 && process.argv[outputIndex + 1]) {
    CONFIG.outputFile = process.argv[outputIndex + 1];
}

const depthIndex = process.argv.findIndex(arg => arg === '--depth' || arg === '-d');
if (depthIndex !== -1 && process.argv[depthIndex + 1]) {
    CONFIG.maxDepth = parseInt(process.argv[depthIndex + 1]) || CONFIG.maxDepth;
}

// Run the generator
generateDocumentationTree();