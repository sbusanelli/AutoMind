/**
 * Jest Test Setup
 * 
 * Global test configuration and setup for TurboQuant tests
 * 
 * @author AutoMind Team
 * @version 1.0.0
 */

// Set test environment variables
process.env.NODE_ENV = 'test';
process.env.TURBOQUANT_BIT_WIDTH = '3';
process.env.TURBOQUANT_ENABLE_GPU = 'false';
process.env.TURBOQUANT_BATCH_SIZE = '16';
process.env.TURBOQUANT_MAX_MEMORY_USAGE = '512';

// Global test timeout
jest.setTimeout(30000);

// Mock console methods for cleaner test output
const originalConsole = global.console;

beforeAll(() => {
  global.console = {
    ...originalConsole,
    // Suppress debug logs during tests
    debug: jest.fn(),
    // Keep info, warn, and error for important test output
    info: originalConsole.info,
    warn: originalConsole.warn,
    error: originalConsole.error,
    log: originalConsole.log,
  };
});

afterAll(() => {
  global.console = originalConsole;
});

// Global test utilities
export const createTestVector = (size: number): Float32Array => {
  const vector = new Float32Array(size);
  for (let i = 0; i < size; i++) {
    vector[i] = Math.random() * 2 - 1;
  }
  return vector;
};

export const createTestDocument = (): string => {
  return `This is a test document for TurboQuant integration testing. 
  It contains enough content to demonstrate the compression and optimization capabilities. 
  The document includes various topics and information that can be processed and analyzed 
  using the advanced AI compression techniques implemented in the TurboQuant system.`;
};

export const waitForAsync = (ms: number = 100): Promise<void> => {
  return new Promise(resolve => setTimeout(resolve, ms));
};

// Mock performance API if not available
if (!global.performance) {
  global.performance = {
    now: jest.fn(() => Date.now()),
    mark: jest.fn(),
    measure: jest.fn(),
    getEntriesByName: jest.fn(),
    getEntriesByType: jest.fn(),
    clearMarks: jest.fn(),
    clearMeasures: jest.fn(),
    getEntries: jest.fn(),
    setResourceTimingBufferSize: jest.fn(),
    toJSON: jest.fn(),
  };
}
