/**
 * Shared utilities for agentic development scripts
 * 
 * Provides common functions for JSON file handling, logging, and data processing.
 */

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

/**
 * Load JSON file with error handling and logging
 * @param {string} filePath - Path to JSON file
 * @returns {Object} Parsed JSON object or empty object on error
 */
function loadJSON(filePath) {
    try {
        return JSON.parse(fs.readFileSync(filePath, 'utf8'));
    } catch (error) {
        console.error(`Error loading ${filePath}:`, error.message);
        return {};
    }
}

/**
 * Save JSON file with error handling and logging
 * @param {string} filePath - Path to save JSON file
 * @param {Object} data - Data to save as JSON
 * @returns {boolean} Success status
 */
function saveJSON(filePath, data) {
    try {
        fs.writeFileSync(filePath, JSON.stringify(data, null, 2));
        console.log(`✅ Updated: ${path.basename(filePath)}`);
        return true;
    } catch (error) {
        console.error(`Error saving ${filePath}:`, error.message);
        return false;
    }
}

/**
 * Generate a unique ID for tracking purposes
 * @returns {string} Unique hexadecimal ID
 */
function generateUniqueId() {
    return crypto.randomBytes(8).toString('hex');
}

/**
 * Get current ISO timestamp
 * @returns {string} Current timestamp in ISO format
 */
function getCurrentTimestamp() {
    return new Date().toISOString();
}

/**
 * Ensure directory exists, creating it if necessary
 * @param {string} dirPath - Directory path to ensure exists
 * @returns {boolean} Success status
 */
function ensureDirectoryExists(dirPath) {
    try {
        if (!fs.existsSync(dirPath)) {
            fs.mkdirSync(dirPath, { recursive: true });
            console.log(`Created directory: ${dirPath}`);
        }
        return true;
    } catch (error) {
        console.error(`Error creating directory ${dirPath}:`, error.message);
        return false;
    }
}

/**
 * Parse command line arguments into options object
 * @param {string[]} args - Command line arguments
 * @returns {Object} Parsed options
 */
function parseArguments(args) {
    const options = {};
    args.forEach(arg => {
        const [key, value] = arg.split('=');
        const cleanKey = key.replace('--', '');
        options[cleanKey] = value;
    });
    return options;
}

/**
 * Validate required arguments are present
 * @param {Object} options - Parsed options
 * @param {string[]} required - Required argument names
 * @throws {Error} If required arguments are missing
 */
function validateRequiredArguments(options, required) {
    for (const field of required) {
        if (!options[field]) {
            throw new Error(`Missing required argument: --${field}`);
        }
    }
}

/**
 * Get tracking directory path
 * @param {string} baseDir - Base directory (defaults to script directory)
 * @returns {string} Path to tracking directory
 */
function getTrackingDirectory(baseDir = __dirname) {
    return path.join(baseDir, '..', 'branch-tracking');
}

/**
 * Log message with timestamp and level
 * @param {string} message - Message to log
 * @param {string} level - Log level (INFO, ERROR, WARN)
 * @param {string} logFile - Optional log file path
 */
function logMessage(message, level = 'INFO', logFile = null) {
    const timestamp = new Date().toISOString();
    const logMessage = `[${timestamp}] ${level}: ${message}`;
    console.log(logMessage);
    
    if (logFile) {
        try {
            fs.appendFileSync(logFile, logMessage + '\n');
        } catch (error) {
            console.error(`Error writing to log file ${logFile}:`, error.message);
        }
    }
}

module.exports = {
    loadJSON,
    saveJSON,
    generateUniqueId,
    getCurrentTimestamp,
    ensureDirectoryExists,
    parseArguments,
    validateRequiredArguments,
    getTrackingDirectory,
    logMessage
};