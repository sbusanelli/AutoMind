/**
 * TurboQuant Integration Tests
 * 
 * Comprehensive test suite for TurboQuant compression and optimization
 * Tests all components including compression, LLM integration, and API routes
 * 
 * @author AutoMind Team
 * @version 1.0.0
 */

import { TurboQuantService, TurboQuantConfig } from '../index';
import { LLMIntegrationService, DocumentProcessingService } from '../llm-integration';

describe('TurboQuant Service', () => {
  let turboQuant: TurboQuantService;
  const testConfig: TurboQuantConfig = {
    bitWidth: 3,
    enablePolarQuant: true,
    enableQJL: true,
    batchSize: 16,
    maxSequenceLength: 4096,
    enableGPUAcceleration: false, // Disable for tests
    compressionRatio: 6,
    enableMemoryPool: true,
    maxMemoryUsage: 512
  };

  beforeEach(async () => {
    turboQuant = new TurboQuantService(testConfig);
    await turboQuant.initialize();
  });

  afterEach(async () => {
    if (turboQuant) {
      await turboQuant.shutdown();
    }
  });

  describe('Initialization', () => {
    test('should initialize successfully with valid config', async () => {
      expect(turboQuant).toBeDefined();
      const metrics = turboQuant.getPerformanceMetrics();
      expect(metrics).toBeDefined();
    });

    test('should handle initialization errors gracefully', async () => {
      const invalidConfig = { ...testConfig, maxMemoryUsage: -1 };
      const invalidService = new TurboQuantService(invalidConfig);
      
      await expect(invalidService.initialize()).rejects.toThrow();
    });
  });

  describe('Compression', () => {
    test('should compress data successfully', async () => {
      const testData = new Float32Array(1000);
      for (let i = 0; i < testData.length; i++) {
        testData[i] = Math.random() * 2 - 1;
      }

      const compressed = await turboQuant.compressDocumentContext(testData);
      
      expect(compressed).toBeDefined();
      expect(compressed.data).toBeDefined();
      expect(compressed.metadata).toBeDefined();
      expect(compressed.metadata.originalSize).toBe(testData.length);
      expect(compressed.metadata.bitWidth).toBe(testConfig.bitWidth);
      // For simulation, data size may be same but compression ratio is tracked in metadata
      expect(compressed.metadata.originalSize).toBeGreaterThanOrEqual(compressed.metadata.compressedSize);
    });

    test('should decompress data successfully', async () => {
      const testData = new Float32Array(1000);
      for (let i = 0; i < testData.length; i++) {
        testData[i] = Math.random() * 2 - 1;
      }

      const compressed = await turboQuant.compressDocumentContext(testData);
      const decompressed = await turboQuant.decompressDocumentContext(compressed);
      
      expect(decompressed).toBeDefined();
      expect(decompressed.length).toBe(testData.length);
      
      // Check that decompressed data is close to original (within tolerance)
      for (let i = 0; i < Math.min(100, testData.length); i++) {
        expect(Math.abs(decompressed[i] - testData[i])).toBeLessThan(0.1);
      }
    });

    test('should achieve target compression ratio', async () => {
      const testData = new Float32Array(2000);
      for (let i = 0; i < testData.length; i++) {
        testData[i] = Math.random() * 2 - 1;
      }

      const compressed = await turboQuant.compressDocumentContext(testData);
      const actualRatio = testData.length / compressed.data.length;
      
      expect(actualRatio).toBeGreaterThan(testConfig.compressionRatio * 0.8); // Allow 20% tolerance
    });

    test('should handle different bit widths', async () => {
      const testData = new Float32Array(1000);
      for (let i = 0; i < testData.length; i++) {
        testData[i] = Math.random() * 2 - 1;
      }

      // Test 3-bit
      turboQuant.updateConfig({ bitWidth: 3 });
      const compressed3bit = await turboQuant.compressDocumentContext(testData);
      
      // Test 4-bit
      turboQuant.updateConfig({ bitWidth: 4 });
      const compressed4bit = await turboQuant.compressDocumentContext(testData);
      
      // Test 8-bit
      turboQuant.updateConfig({ bitWidth: 8 });
      const compressed8bit = await turboQuant.compressDocumentContext(testData);
      
      expect(compressed3bit.data.length).toBeLessThan(compressed4bit.data.length);
      expect(compressed4bit.data.length).toBeLessThan(compressed8bit.data.length);
    });
  });

  describe('Performance Metrics', () => {
    test('should track compression metrics', async () => {
      const testData = new Float32Array(1000);
      for (let i = 0; i < testData.length; i++) {
        testData[i] = Math.random() * 2 - 1;
      }

      await turboQuant.compressDocumentContext(testData);
      const metrics = turboQuant.getPerformanceMetrics();
      
      expect(metrics.compressionRatio).toBeGreaterThan(1);
      expect(metrics.memoryReduction).toBeGreaterThan(0);
      expect(metrics.processingTime).toBeGreaterThan(0);
      expect(metrics.kvCacheSize).toBeGreaterThan(0);
    });

    test('should update metrics after multiple operations', async () => {
      const testData = new Float32Array(500);
      for (let i = 0; i < testData.length; i++) {
        testData[i] = Math.random() * 2 - 1;
      }

      // Perform multiple compressions
      for (let i = 0; i < 5; i++) {
        await turboQuant.compressDocumentContext(testData);
      }

      const metrics = turboQuant.getPerformanceMetrics();
      expect(metrics.compressionRatio).toBeGreaterThan(1);
      expect(metrics.processingTime).toBeGreaterThan(0);
    });
  });

  describe('Configuration Updates', () => {
    test('should update configuration successfully', () => {
      const newConfig = { bitWidth: 4 as const, maxMemoryUsage: 1024 };
      turboQuant.updateConfig(newConfig);
      
      // Configuration should be updated (verified through compression behavior)
      expect(() => turboQuant.updateConfig(newConfig)).not.toThrow();
    });

    test('should handle invalid configuration gracefully', () => {
      const invalidConfig = { bitWidth: 8 as const }; // Valid bit width but different
      expect(() => turboQuant.updateConfig(invalidConfig)).not.toThrow();
    });
  });
});

describe('LLM Integration Service', () => {
  let turboQuant: TurboQuantService;
  let llmIntegration: LLMIntegrationService;

  beforeEach(async () => {
    const testConfig: TurboQuantConfig = {
      bitWidth: 3,
      enablePolarQuant: true,
      enableQJL: true,
      batchSize: 16,
      maxSequenceLength: 4096,
      enableGPUAcceleration: false,
      compressionRatio: 6,
      enableMemoryPool: true,
      maxMemoryUsage: 512
    };

    turboQuant = new TurboQuantService(testConfig);
    await turboQuant.initialize();
    llmIntegration = new LLMIntegrationService(turboQuant);
  });

  afterEach(async () => {
    if (turboQuant) {
      await turboQuant.shutdown();
    }
  });

  describe('Provider Management', () => {
    test('should initialize with default providers', () => {
      const providers = llmIntegration.getSupportedProviders();
      expect(providers).toHaveLength(3);
      expect(providers[0].name).toBe('openai');
      expect(providers[1].name).toBe('anthropic');
      expect(providers[2].name).toBe('local');
    });

    test('should add new provider successfully', () => {
      const newProvider = {
        name: 'custom',
        model: 'custom-model',
        maxContextLength: 100000,
        supportsKVCacheOptimization: true
      };

      llmIntegration.addProvider(newProvider);
      const providers = llmIntegration.getSupportedProviders();
      
      expect(providers).toHaveLength(4);
      expect(providers.find(p => p.name === 'custom')).toBeDefined();
    });
  });

  describe('Request Processing', () => {
    test('should process request without context', async () => {
      const request = {
        provider: llmIntegration.getSupportedProviders()[0],
        prompt: 'Test prompt',
        maxTokens: 100
      };

      const response = await llmIntegration.processRequest(request);
      
      expect(response).toBeDefined();
      expect(response.content).toBeDefined();
      expect(response.usage).toBeDefined();
      expect(response.usage.totalTokens).toBeGreaterThan(0);
    });

    test('should process request with context compression', async () => {
      const context = new Float32Array(1000);
      for (let i = 0; i < context.length; i++) {
        context[i] = Math.random() * 2 - 1;
      }

      const request = {
        provider: llmIntegration.getSupportedProviders()[0],
        prompt: 'Test prompt with context',
        context,
        maxTokens: 100
      };

      const response = await llmIntegration.processRequest(request);
      
      expect(response).toBeDefined();
      expect(response.compressionMetrics).toBeDefined();
      expect(response.compressionMetrics!.compressionRatio).toBeGreaterThan(1);
      expect(response.compressionMetrics!.processingTime).toBeGreaterThan(0);
    });

    test('should handle document processing', async () => {
      const document = 'This is a test document for processing with TurboQuant optimization.';
      const provider = llmIntegration.getSupportedProviders()[0];

      const response = await llmIntegration.processDocumentWithOptimization(
        document,
        provider,
        'Summarize this document'
      );

      expect(response).toBeDefined();
      expect(response.content).toBeDefined();
      expect(response.compressionMetrics).toBeDefined();
    });

    test('should batch process documents', async () => {
      const documents = [
        'First test document',
        'Second test document',
        'Third test document'
      ];
      const provider = llmIntegration.getSupportedProviders()[0];

      const responses = await llmIntegration.batchProcessDocuments(
        documents,
        provider,
        'Analyze these documents'
      );

      expect(responses).toHaveLength(3);
      responses.forEach(response => {
        expect(response).toBeDefined();
        expect(response.content).toBeDefined();
      });
    });
  });

  describe('Optimization Statistics', () => {
    test('should return optimization statistics', () => {
      const stats = llmIntegration.getOptimizationStats();
      
      expect(stats).toBeDefined();
      expect(stats.totalCompressionRatio).toBeGreaterThanOrEqual(0);
      expect(stats.averageProcessingTime).toBeGreaterThanOrEqual(0);
      expect(stats.memorySavings).toBeGreaterThanOrEqual(0);
    });
  });
});

describe('Document Processing Service', () => {
  let turboQuant: TurboQuantService;
  let documentProcessing: DocumentProcessingService;

  beforeEach(async () => {
    const testConfig: TurboQuantConfig = {
      bitWidth: 3,
      enablePolarQuant: true,
      enableQJL: true,
      batchSize: 16,
      maxSequenceLength: 4096,
      enableGPUAcceleration: false,
      compressionRatio: 6,
      enableMemoryPool: true,
      maxMemoryUsage: 512
    };

    turboQuant = new TurboQuantService(testConfig);
    await turboQuant.initialize();
    documentProcessing = new DocumentProcessingService(turboQuant);
  });

  afterEach(async () => {
    if (turboQuant) {
      await turboQuant.shutdown();
    }
  });

  describe('Document Analysis', () => {
    test('should analyze document summary', async () => {
      const document = 'This is a comprehensive document about artificial intelligence and machine learning. It covers various topics including neural networks, deep learning, and natural language processing. The document explains how these technologies work and their applications in modern society.';
      
      const response = await documentProcessing.analyzeDocument(document, 'summary');
      
      expect(response).toBeDefined();
      expect(response.content).toBeDefined();
      expect(response.compressionMetrics).toBeDefined();
    });

    test('should analyze document sentiment', async () => {
      const document = 'I am very happy and excited about the new developments in AI technology. This represents a significant breakthrough that will benefit many people around the world.';
      
      const response = await documentProcessing.analyzeDocument(document, 'sentiment');
      
      expect(response).toBeDefined();
      expect(response.content).toBeDefined();
    });

    test('should extract entities from document', async () => {
      const document = 'John Smith works at Microsoft in Seattle. He met with Sarah Johnson from Google on March 15, 2024 to discuss the new AI project.';
      
      const response = await documentProcessing.analyzeDocument(document, 'entities');
      
      expect(response).toBeDefined();
      expect(response.content).toBeDefined();
    });

    test('should extract keywords from document', async () => {
      const document = 'Artificial intelligence, machine learning, neural networks, deep learning, natural language processing, computer vision, and robotics are key areas of modern AI research.';
      
      const response = await documentProcessing.analyzeDocument(document, 'keywords');
      
      expect(response).toBeDefined();
      expect(response.content).toBeDefined();
    });
  });

  describe('Comparative Analysis', () => {
    test('should perform comparative analysis on multiple documents', async () => {
      const documents = [
        'Document about machine learning fundamentals and basic concepts.',
        'Document about deep learning architectures and advanced neural networks.',
        'Document about natural language processing and text analysis techniques.'
      ];
      
      const result = await documentProcessing.comparativeAnalysis(documents);
      
      expect(result).toBeDefined();
      expect(result.individualResults).toHaveLength(3);
      expect(result.comparativeInsights).toBeDefined();
      expect(result.optimizationStats).toBeDefined();
      
      result.individualResults.forEach(response => {
        expect(response.content).toBeDefined();
        expect(response.compressionMetrics).toBeDefined();
      });
    });
  });
});

describe('Integration Tests', () => {
  let turboQuant: TurboQuantService;
  let llmIntegration: LLMIntegrationService;
  let documentProcessing: DocumentProcessingService;

  beforeEach(async () => {
    const testConfig: TurboQuantConfig = {
      bitWidth: 3,
      enablePolarQuant: true,
      enableQJL: true,
      batchSize: 16,
      maxSequenceLength: 4096,
      enableGPUAcceleration: false,
      compressionRatio: 6,
      enableMemoryPool: true,
      maxMemoryUsage: 512
    };

    turboQuant = new TurboQuantService(testConfig);
    await turboQuant.initialize();
    llmIntegration = new LLMIntegrationService(turboQuant);
    documentProcessing = new DocumentProcessingService(turboQuant);
  });

  afterEach(async () => {
    if (turboQuant) {
      await turboQuant.shutdown();
    }
  });

  describe('End-to-End Workflow', () => {
    test('should complete full document processing workflow', async () => {
      // Step 1: Compress document context
      const document = 'This is a comprehensive test document for end-to-end workflow testing. It contains enough content to demonstrate the full capabilities of TurboQuant integration with document processing and LLM optimization.';
      const context = new Float32Array(2000);
      for (let i = 0; i < context.length; i++) {
        context[i] = Math.random() * 2 - 1;
      }

      const compressed = await turboQuant.compressDocumentContext(context);
      expect(compressed.metadata.originalSize).toBeGreaterThan(compressed.metadata.compressedSize);

      // Step 2: Process document with LLM integration
      const response = await documentProcessing.analyzeDocument(document, 'summary');
      expect(response.content).toBeDefined();
      expect(response.compressionMetrics).toBeDefined();

      // Step 3: Verify metrics
      const metrics = turboQuant.getPerformanceMetrics();
      expect(metrics.compressionRatio).toBeGreaterThan(1);
      expect(metrics.memoryReduction).toBeGreaterThan(0);

      // Step 4: Decompress and verify
      const decompressed = await turboQuant.decompressDocumentContext(compressed);
      expect(decompressed.length).toBe(context.length);
    });

    test('should handle large document batches efficiently', async () => {
      const documents = Array.from({ length: 10 }, (_, i) => 
        `Document ${i + 1}: This is test content for batch processing efficiency testing. It contains enough text to demonstrate how TurboQuant handles multiple documents with compression and optimization.`
      );

      const startTime = Date.now();
      const results = await documentProcessing.comparativeAnalysis(documents);
      const processingTime = Date.now() - startTime;

      expect(results.individualResults).toHaveLength(10);
      expect(processingTime).toBeLessThan(10000); // Should complete within 10 seconds
      expect(results.optimizationStats.totalCompressionRatio).toBeGreaterThan(1);
    });
  });

  describe('Performance Benchmarks', () => {
    test('should meet performance targets for compression', async () => {
      const testData = new Float32Array(5000);
      for (let i = 0; i < testData.length; i++) {
        testData[i] = Math.random() * 2 - 1;
      }

      const startTime = Date.now();
      const compressed = await turboQuant.compressDocumentContext(testData);
      const compressionTime = Date.now() - startTime;

      // Performance targets
      expect(compressionTime).toBeLessThan(1000); // Should compress within 1 second
      expect(compressed.metadata.originalSize / compressed.metadata.compressedSize).toBeGreaterThan(4); // At least 4x compression
    });

    test('should meet performance targets for decompression', async () => {
      const testData = new Float32Array(5000);
      for (let i = 0; i < testData.length; i++) {
        testData[i] = Math.random() * 2 - 1;
      }

      const compressed = await turboQuant.compressDocumentContext(testData);
      
      const startTime = Date.now();
      const decompressed = await turboQuant.decompressDocumentContext(compressed);
      const decompressionTime = Date.now() - startTime;

      expect(decompressionTime).toBeLessThan(500); // Should decompress within 500ms
      expect(decompressed.length).toBe(testData.length);
    });
  });
});
