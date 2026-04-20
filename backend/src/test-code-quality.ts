/**
 * Test file for OpenCode AI code review
 * This file contains intentional issues for testing AI review capabilities
 */

import { express, Request, Response } from 'express';

// Security issues
const userInput = req.query.userInput; // TODO: No input validation
const sqlQuery = "SELECT * FROM users WHERE id = " + userInput; // SQL injection vulnerability

// Performance issues
function findUserSlow(users: any[], id: number) {
    for (let i = 0; i < users.length; i++) { // Inefficient loop
        if (users[i].id === id) {
            return users[i];
        }
    }
    return null;
}

// Code quality issues
function processData(data: any) {
    var result = data.map((item: any) => { // Using var instead of let/const
        return item.value * 2;
    });
    return result;
}

// Long line that exceeds 120 characters for maintainability testing - this line is intentionally too long to test the line length validation in the AI code review service

// Missing error handling
async function fetchUserData(userId: string) {
    const response = await fetch(`/api/users/${userId}`); // No error handling
    const data = await response.json();
    return data;
}

// Hardcoded credentials (security issue)
const dbPassword = "admin123"; // Hardcoded password

// Unused variables
const unusedVar = "this variable is never used";

// Missing type annotations
function calculateTotal(items) { // No type annotations for parameters
    return items.reduce((sum, item) => sum + item.price, 0);
}

// Potential null reference
function getUserEmail(user: any) {
    return user.email.toLowerCase(); // No null check for user.email
}

// Console.log in production code
console.log("Debug information that should not be in production");

// Eval usage (critical security issue)
const dynamicCode = "return " + userInput;
const result = eval(dynamicCode); // Dangerous eval usage

export { findUserSlow, processData, fetchUserData, calculateTotal, getUserEmail };
