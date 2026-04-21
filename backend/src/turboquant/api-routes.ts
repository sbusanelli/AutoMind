/**
 * TurboQuant API Routes
 * 
 * REST API endpoints for TurboQuant compression and optimization services
 * Integrates with AutoMind's document processing pipeline
 * 
 * @author AutoMind Team
 * @version 1.0.0
 */

import { Router, Request, Response } from 'express';
import { TurboQuantService, TurboQuantConfig } from './index';
import { LLMIntegrationService, DocumentProcessingService } from './llm-integration';
import { Logger } from '../utils/logger';

const router = Router();
const logger = new Logger('TurboQuantAPI');

// Global TurboQuant service instance
let turboQuantService: TurboQuantService;
let llmIntegration: LLMIntegrationService;
let documentProcessing: DocumentProcessingService;

/**
 * Initialize TurboQuant services
 */
async function initializeServices(): Promise<void> {
  if (!turboQuantService) {
    const config: TurboQuantConfig = {
      bitWidth: 3,
      enablePolarQuant: true,
      enableQJL: true,
      batchSize: 32,
      maxSequenceLength: 8192,
      enableGPUAcceleration: true,
      compressionRatio: 6,
      enableMemoryPool: true,
      maxMemoryUsage: 1024
    };

    turboQuantService = new TurboQuantService(config);
    await turboQuantService.initialize();

    llmIntegration = new LLMIntegrationService(turboQuantService);
    documentProcessing = new DocumentProcessingService(turboQuantService);

    logger.info('TurboQuant services initialized');
  }
}

/**
 * POST /api/turboquant/compress
 * Compress data using TurboQuant algorithm
 */
router.post('/compress', async (req: Request, res: Response) => {
  try {
    await initializeServices();

    const { data, bitWidth } = req.body;

    if (!data || !Array.isArray(data)) {
      return res.status(400).json({
        error: 'Invalid request: data array is required'
      });
    }

    // Convert data to Float32Array
    const floatData = new Float32Array(data);
    
    // Update bit width if specified
    if (bitWidth && [3, 4, 8].includes(bitWidth)) {
      turboQuantService.updateConfig({ bitWidth });
    }

    const startTime = Date.now();
    const compressed = await turboQuantService.compressDocumentContext(floatData);
    const processingTime = Date.now() - startTime;

    res.json({
      success: true,
      data: Array.from(compressed.data),
      metadata: compressed.metadata,
      processingTime,
      metrics: turboQuantService.getPerformanceMetrics()
    });

  } catch (error) {
    logger.error('Compression failed:', error);
    res.status(500).json({
      error: 'Compression failed',
      message: error.message
    });
  }
});

/**
 * POST /api/turboquant/decompress
 * Decompress TurboQuant compressed data
 */
router.post('/decompress', async (req: Request, res: Response) => {
  try {
    await initializeServices();

    const { data, metadata } = req.body;

    if (!data || !Array.isArray(data) || !metadata) {
      return res.status(400).json({
        error: 'Invalid request: data array and metadata are required'
      });
    }

    // Reconstruct QuantizedVector
    const quantizedVector = {
      data: new Float32Array(data),
      metadata
    };

    const startTime = Date.now();
    const decompressed = await turboQuantService.decompressDocumentContext(quantizedVector);
    const processingTime = Date.now() - startTime;

    res.json({
      success: true,
      data: Array.from(decompressed),
      processingTime,
      originalSize: metadata.originalSize,
      decompressedSize: decompressed.length
    });

  } catch (error) {
    logger.error('Decompression failed:', error);
    res.status(500).json({
      error: 'Decompression failed',
      message: error.message
    });
  }
});

/**
 * POST /api/turboquant/process-document
 * Process document with TurboQuant optimization
 */
router.post('/process-document', async (req: Request, res: Response) => {
  try {
    await initializeServices();

    const { document, analysisType, provider } = req.body;

    if (!document || typeof document !== 'string') {
      return res.status(400).json({
        error: 'Invalid request: document string is required'
      });
    }

    const validAnalysisTypes = ['summary', 'sentiment', 'entities', 'keywords'];
    const analysis = analysisType || 'summary';
    
    if (!validAnalysisTypes.includes(analysis)) {
      return res.status(400).json({
        error: `Invalid analysisType. Must be one of: ${validAnalysisTypes.join(', ')}`
      });
    }

    const startTime = Date.now();
    const result = await documentProcessing.analyzeDocument(document, analysis);
    const processingTime = Date.now() - startTime;

    res.json({
      success: true,
      result,
      processingTime,
      metrics: turboQuantService.getPerformanceMetrics()
    });

  } catch (error) {
    logger.error('Document processing failed:', error);
    res.status(500).json({
      error: 'Document processing failed',
      message: error.message
    });
  }
});

/**
 * POST /api/turboquant/batch-process
 * Batch process multiple documents
 */
router.post('/batch-process', async (req: Request, res: Response) => {
  try {
    await initializeServices();

    const { documents, analysisType, provider } = req.body;

    if (!documents || !Array.isArray(documents) || documents.length === 0) {
      return res.status(400).json({
        error: 'Invalid request: documents array is required'
      });
    }

    if (documents.length > 50) {
      return res.status(400).json({
        error: 'Too many documents: maximum 50 documents per batch'
      });
    }

    const startTime = Date.now();
    const results = await documentProcessing.comparativeAnalysis(documents);
    const processingTime = Date.now() - startTime;

    res.json({
      success: true,
      results,
      processingTime,
      documentCount: documents.length,
      metrics: turboQuantService.getPerformanceMetrics()
    });

  } catch (error) {
    logger.error('Batch processing failed:', error);
    res.status(500).json({
      error: 'Batch processing failed',
      message: error.message
    });
  }
});

/**
 * GET /api/turboquant/metrics
 * Get current performance metrics
 */
router.get('/metrics', async (req: Request, res: Response) => {
  try {
    await initializeServices();

    const metrics = turboQuantService.getPerformanceMetrics();
    const optimizationStats = llmIntegration.getOptimizationStats();

    res.json({
      success: true,
      metrics,
      optimizationStats,
      providers: llmIntegration.getSupportedProviders()
    });

  } catch (error) {
    logger.error('Failed to get metrics:', error);
    res.status(500).json({
      error: 'Failed to get metrics',
      message: error.message
    });
  }
});

/**
 * POST /api/turboquant/config
 * Update TurboQuant configuration
 */
router.post('/config', async (req: Request, res: Response) => {
  try {
    await initializeServices();

    const config = req.body;
    
    // Validate configuration
    const validConfig: Partial<TurboQuantConfig> = {};
    
    if (config.bitWidth && [3, 4, 8].includes(config.bitWidth)) {
      validConfig.bitWidth = config.bitWidth;
    }
    
    if (typeof config.enableGPUAcceleration === 'boolean') {
      validConfig.enableGPUAcceleration = config.enableGPUAcceleration;
    }
    
    if (typeof config.compressionRatio === 'number' && config.compressionRatio > 0) {
      validConfig.compressionRatio = config.compressionRatio;
    }
    
    if (typeof config.maxMemoryUsage === 'number' && config.maxMemoryUsage > 0) {
      validConfig.maxMemoryUsage = config.maxMemoryUsage;
    }

    turboQuantService.updateConfig(validConfig);

    res.json({
      success: true,
      config: validConfig,
      currentMetrics: turboQuantService.getPerformanceMetrics()
    });

  } catch (error) {
    logger.error('Configuration update failed:', error);
    res.status(500).json({
      error: 'Configuration update failed',
      message: error.message
    });
  }
});

/**
 * GET /api/turboquant/health
 * Health check endpoint
 */
router.get('/health', async (req: Request, res: Response) => {
  try {
    const isInitialized = !!turboQuantService;
    const metrics = isInitialized ? turboQuantService.getPerformanceMetrics() : null;

    res.json({
      success: true,
      status: isInitialized ? 'healthy' : 'initializing',
      metrics,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    logger.error('Health check failed:', error);
    res.status(500).json({
      error: 'Health check failed',
      message: error.message
    });
  }
});

/**
 * POST /api/turboquant/benchmark
 * Run performance benchmark
 */
router.post('/benchmark', async (req: Request, res: Response) => {
  try {
    await initializeServices();

    const { dataSize = 1000, iterations = 10 } = req.body;

    if (dataSize < 100 || dataSize > 10000) {
      return res.status(400).json({
        error: 'Invalid dataSize: must be between 100 and 10000'
      });
    }

    if (iterations < 1 || iterations > 100) {
      return res.status(400).json({
        error: 'Invalid iterations: must be between 1 and 100'
      });
    }

    // Generate test data
    const testData = new Float32Array(dataSize);
    for (let i = 0; i < dataSize; i++) {
      testData[i] = Math.random() * 2 - 1;
    }

    const benchmarkResults = {
      compression: {
        totalTime: 0,
        averageTime: 0,
        compressionRatios: [] as number[]
      },
      decompression: {
        totalTime: 0,
        averageTime: 0
      },
      memory: {
        originalSize: dataSize * 4, // 4 bytes per float32
        compressedSizes: [] as number[],
        averageCompressionRatio: 0
      }
    };

    // Run benchmark iterations
    for (let i = 0; i < iterations; i++) {
      // Compression benchmark
      const compressStart = Date.now();
      const compressed = await turboQuantService.compressDocumentContext(testData);
      const compressTime = Date.now() - compressStart;
      
      benchmarkResults.compression.totalTime += compressTime;
      benchmarkResults.compression.compressionRatios.push(
        compressed.metadata.originalSize / compressed.metadata.compressedSize
      );
      benchmarkResults.memory.compressedSizes.push(compressed.metadata.compressedSize);

      // Decompression benchmark
      const decompressStart = Date.now();
      await turboQuantService.decompressDocumentContext(compressed);
      const decompressTime = Date.now() - decompressStart;
      
      benchmarkResults.decompression.totalTime += decompressTime;
    }

    // Calculate averages
    benchmarkResults.compression.averageTime = benchmarkResults.compression.totalTime / iterations;
    benchmarkResults.decompression.averageTime = benchmarkResults.decompression.totalTime / iterations;
    benchmarkResults.memory.averageCompressionRatio = 
      benchmarkResults.compression.compressionRatios.reduce((a, b) => a + b, 0) / iterations;

    res.json({
      success: true,
      benchmark: benchmarkResults,
      iterations,
      dataSize,
      currentMetrics: turboQuantService.getPerformanceMetrics()
    });

  } catch (error) {
    logger.error('Benchmark failed:', error);
    res.status(500).json({
      error: 'Benchmark failed',
      message: error.message
    });
  }
});

export default router;
