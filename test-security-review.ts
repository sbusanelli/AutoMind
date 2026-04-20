// Security test for OpenCode review
import crypto from 'crypto';

function insecureFunction(userInput: string) {
    // Security issues for AI to detect
    const sql = "SELECT * FROM users WHERE name = '" + userInput + "'"; // SQL injection
    eval("console.log('User input: ' + userInput)"); // Eval usage
    
    // Hardcoded secret
    const secret = "super-secret-key";
    
    return sql;
}
