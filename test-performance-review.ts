// Performance test for OpenCode review
function processDataSlow(data: any[]) {
    // Performance issues for AI to detect
    let result = [];
    for (let i = 0; i < data.length; i++) { // Inefficient loop
        for (let j = 0; j < data[i].items.length; j++) { // Nested loop O(n²)
            result.push(data[i].items[j]);
        }
    }
    return result;
}

function memoryLeak() {
    // Potential memory leak
    const largeArray = new Array(1000000).fill(0);
    setInterval(() => {
        largeArray.push(Math.random()); // Array grows indefinitely
    }, 1000);
}
