import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import { createServer } from 'http';
import { Server as SocketIOServer } from 'socket.io';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

const app = express();
const server = createServer(app);
const io = new SocketIOServer(server, {
  cors: {
    origin: process.env.CORS_ORIGIN || "http://localhost:3000",
    methods: ["GET", "POST"]
  }
});

const PORT = process.env.PORT || 5000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});
app.use(limiter);

// Health check endpoints
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    service: 'automind-backend'
  });
});

app.get('/ready', (req, res) => {
  res.status(200).json({
    status: 'ready',
    timestamp: new Date().toISOString(),
    service: 'automind-backend'
  });
});

// API routes
app.get('/api/status', (req, res) => {
  res.json({
    message: 'AutoMind Backend API is running',
    version: '1.0.0',
    environment: process.env.NODE_ENV || 'development',
    timestamp: new Date().toISOString()
  });
});

// Basic AI endpoint
app.post('/api/ai/chat', async (req, res) => {
  try {
    const { message } = req.body;
    
    if (!message) {
      return res.status(400).json({ error: 'Message is required' });
    }

    // Simple mock response for now
    const response = {
      id: Date.now(),
      message: `AutoMind AI response to: "${message}"`,
      timestamp: new Date().toISOString(),
      confidence: 0.95
    };

    res.json(response);
  } catch (error) {
    console.error('AI Chat Error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// TurboQuant API routes
import { TurboQuantService, TurboQuantConfig } from './turboquant/index';
import { LLMIntegrationService, DocumentProcessingService } from './turboquant/llm-integration';
import Logger from './utils/logger';

const logger = new Logger('TurboQuantAPI');

// Initialize TurboQuant services
let turboQuantService: TurboQuantService;
let llmIntegration: LLMIntegrationService;
let documentProcessing: DocumentProcessingService;

const initializeTurboQuant = async () => {
  try {
    const config: TurboQuantConfig = {
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

    turboQuantService = new TurboQuantService(config);
    await turboQuantService.initialize();
    
    llmIntegration = new LLMIntegrationService(turboQuantService);
    documentProcessing = new DocumentProcessingService(turboQuantService);
    
    logger.info('TurboQuant services initialized successfully');
  } catch (error) {
    logger.error('Failed to initialize TurboQuant services:', error);
  }
};

// Initialize services on startup
initializeTurboQuant();

// TurboQuant compression endpoint
app.post('/api/turboquant/compress', async (req, res) => {
  try {
    const { data, bitWidth = 3 } = req.body;
    
    if (!data || !Array.isArray(data)) {
      return res.status(400).json({ error: 'Data array is required' });
    }

    if (!turboQuantService) {
      return res.status(503).json({ error: 'TurboQuant service not available' });
    }

    const floatData = new Float32Array(data);
    const result = await turboQuantService.compressDocumentContext(floatData);
    
    res.json({
      success: true,
      data: Array.from(result.data),
      metadata: result.metadata,
      processingTime: Date.now()
    });
  } catch (error) {
    logger.error('Compression error:', error);
    res.status(500).json({ error: 'Compression failed' });
  }
});

// TurboQuant decompression endpoint
app.post('/api/turboquant/decompress', async (req, res) => {
  try {
    const { data, metadata } = req.body;
    
    if (!data || !metadata) {
      return res.status(400).json({ error: 'Data and metadata are required' });
    }

    if (!turboQuantService) {
      return res.status(503).json({ error: 'TurboQuant service not available' });
    }

    const floatData = new Float32Array(data);
    const result = await turboQuantService.decompressDocumentContext({ data: floatData, metadata });
    
    res.json({
      success: true,
      data: Array.from(result),
      processingTime: Date.now()
    });
  } catch (error) {
    logger.error('Decompression error:', error);
    res.status(500).json({ error: 'Decompression failed' });
  }
});

// TurboQuant metrics endpoint
app.get('/api/turboquant/metrics', async (req, res) => {
  try {
    if (!turboQuantService) {
      return res.status(503).json({ error: 'TurboQuant service not available' });
    }

    const metrics = turboQuantService.getPerformanceMetrics();
    res.json({
      success: true,
      metrics,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    logger.error('Metrics error:', error);
    res.status(500).json({ error: 'Failed to get metrics' });
  }
});

// Document processing endpoint
app.post('/api/turboquant/process-document', async (req, res) => {
  try {
    const { document, analysisType = 'summary', provider = 'openai' } = req.body;
    
    if (!document) {
      return res.status(400).json({ error: 'Document is required' });
    }

    if (!documentProcessing) {
      return res.status(503).json({ error: 'Document processing service not available' });
    }

    const result = await documentProcessing.analyzeDocument(document, analysisType);
    
    res.json({
      success: true,
      result,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    logger.error('Document processing error:', error);
    res.status(500).json({ error: 'Document processing failed' });
  }
});

// TurboQuant health check
app.get('/api/turboquant/health', (req, res) => {
  const health = {
    status: 'healthy',
    services: {
      turboQuant: !!turboQuantService,
      llmIntegration: !!llmIntegration,
      documentProcessing: !!documentProcessing
    },
    timestamp: new Date().toISOString()
  };

  res.json(health);
});

// WebSocket connection handling
io.on('connection', (socket) => {
  console.log('Client connected:', socket.id);
  
  socket.on('join-room', (room) => {
    socket.join(room);
    console.log(`Client ${socket.id} joined room: ${room}`);
  });

  socket.on('disconnect', () => {
    console.log('Client disconnected:', socket.id);
  });
});

// Error handling middleware
app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error(err.stack);
  res.status(500).json({
    error: 'Something went wrong!',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Internal server error'
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: `Route ${req.originalUrl} not found`
  });
});

// Start server
server.listen(PORT, () => {
  console.log(`🚀 AutoMind Backend Server running on port ${PORT}`);
  console.log(`📊 Health: http://localhost:${PORT}/health`);
  console.log(`🔗 API: http://localhost:${PORT}/api`);
  console.log(`🌐 WebSocket: ws://localhost:${PORT}`);
});

export { app, io };
