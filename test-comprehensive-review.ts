// Comprehensive test for OpenCode review
import express from 'express';

class ComplexClass {
    private data: any[] = [];
    
    constructor() {
        this.initializeData();
    }
    
    // Long method (maintainability issue)
    private initializeData() {
        for (let i = 0; i < 1000; i++) {
            this.data.push({
                id: i,
                name: "item_" + i,
                value: Math.random() * 100,
                description: "This is a very long description that makes the line exceed 120 characters which is a maintainability issue that should be detected by the AI code reviewer",
                metadata: {
                    created: new Date(),
                    updated: new Date(),
                    version: "1.0.0",
                    tags: ["test", "data", "sample", "item", "comprehensive", "review", "test"]
                }
            });
        }
    }
    
    // Complex method with multiple issues
    public processData(input: any): any {
        var result = {}; // Using var
        
        // No error handling
        result.processed = input.map((item: any) => {
            return item.value * 2; // No null check for item.value
        });
        
        // Potential null reference
        result.count = result.processed.length;
        
        return result;
    }
}

export default ComplexClass;
