import request from 'supertest';
import express from 'express';
import { app } from '../../index';

describe('API Integration Tests', () => {
  let server: any;

  beforeAll(async () => {
    // Start the server for integration tests
    server = app.listen(0);
  });

  afterAll(async () => {
    // Close the server after tests
    if (server) {
      await server.close();
    }
  });

  describe('Health Check', () => {
    it('should return 200 OK', async () => {
      const response = await request(app)
        .get('/health')
        .expect(200);
      
      expect(response.body).toHaveProperty('status');
      expect(response.body.status).toBe('ok');
      expect(response.body).toHaveProperty('timestamp');
    });
  });

  describe('AI Endpoints', () => {
    describe('POST /api/ai/analyze/:jobId', () => {
      it('should analyze job for optimization', async () => {
        const response = await request(app)
          .post('/api/ai/analyze/test-job-123')
          .send({
            jobData: {
              id: 'test-job-123',
              name: 'Test Job',
              type: 'batch',
              priority: 'medium'
            }
          })
          .expect(200);
        
        expect(response.body).toHaveProperty('analysis');
        expect(response.body.analysis).toHaveProperty('jobOptimization');
      });

      it('should handle invalid job ID', async () => {
        const response = await request(app)
          .post('/api/ai/analyze/invalid-job')
          .send({})
          .expect(404);
        
        expect(response.body).toHaveProperty('error');
      });
    });

    describe('GET /api/ai/predict-failures', () => {
      it('should predict job failures', async () => {
        const response = await request(app)
          .get('/api/ai/predict-failures')
          .expect(200);
        
        expect(response.body).toHaveProperty('prediction');
        expect(response.body.prediction).toHaveProperty('errorPrediction');
      });
    });

    describe('POST /api/ai/optimize-schedule', () => {
      it('should optimize job schedule', async () => {
        const jobs = [
          {
            id: 'job-1',
            name: 'Job 1',
            type: 'batch',
            priority: 'high'
          },
          {
            id: 'job-2',
            name: 'Job 2',
            type: 'batch',
            priority: 'low'
          }
        ];
        
        const response = await request(app)
          .post('/api/ai/optimize-schedule')
          .send({ jobs })
          .expect(200);
        
        expect(response.body).toHaveProperty('schedule');
        expect(response.body.schedule).toBeInstanceOf(Array);
      });
    });

    describe('POST /api/ai/chat', () => {
      it('should handle AI chat requests', async () => {
        const response = await request(app)
          .post('/api/ai/chat')
          .send({
            message: 'How can I optimize my job performance?'
          })
          .expect(200);
        
        expect(response.body).toHaveProperty('response');
        expect(response.body.response).toBeDefined();
      });
    });
  });

  describe('POST /api/ai/explain-failure/:jobId', () => {
    it('should explain job failure', async () => {
      const response = await request(app)
          .post('/api/ai/explain-failure/test-job-123')
          .send({
            error: 'Job failed with timeout',
            context: {
              timeout: 30000,
              retries: 3
            }
          })
          .expect(200);
        
        expect(response.body).toHaveProperty('explanation');
        expect(response.body.explanation).toBeDefined();
      });
    });
  });

  describe('GET /api/ai/anomaly-alerts', () => {
    it('should return anomaly alerts', async () => {
      const response = await request(app)
          .get('/api/ai/anomaly-alerts')
          .expect(200);
        
        expect(response.body).toHaveProperty('anomalies');
        expect(response.body.anomalies).toBeInstanceOf(Array);
      });
    });
  });

  describe('POST /api/ai/performance-insights', () => {
    it('should return performance insights', async () => {
      const response = await request(app)
          .post('/api/ai/performance-insights')
          .send({
            metrics: {
              cpu: 75,
              memory: 60,
              throughput: 1000
            }
          })
          .expect(200);
        
        expect(response.body).toHaveProperty('insights');
        expect(response.body.insights).toHaveProperty('performanceInsights');
      });
    });
  });

  describe('Authentication', () => {
    describe('POST /api/auth/login', () => {
      it('should authenticate user and return token', async () => {
        const response = await request(app)
          .post('/api/auth/login')
          .send({
            username: 'testuser',
            password: 'testpassword'
          })
          .expect(200);
        
        expect(response.body).toHaveProperty('token');
        expect(response.body.token).toBeDefined();
      });
    });

    it('should reject invalid credentials', async () => {
      const response = await request(app)
          .post('/api/auth/login')
          .send({
            username: 'invalid',
            password: 'invalid'
          })
          .expect(401);
        
        expect(response.body).toHaveProperty('error');
      });
    });

    describe('POST /api/auth/refresh', () => {
      it('should refresh access token', async () => {
        const response = await request(app)
          .post('/api/auth/refresh')
          .send({
            refreshToken: 'valid-refresh-token'
          })
          .expect(200);
        
        expect(response.body).toHaveProperty('token');
        expect(response.body.token).toBeDefined();
      });
    });
  });

  describe('Job Management', () => {
    describe('GET /api/jobs', () => {
      it('should return list of jobs', async () => {
        const response = await request(app)
          .get('/api/jobs')
          .expect(200);
        
        expect(response.body).toBeInstanceOf(Array);
        expect(response.body.length).toBeGreaterThan(0);
      });
    });

    describe('POST /api/jobs', () => {
      it('should create a new job', async () => {
        const jobData = {
          name: 'Test Job',
          type: 'batch',
          priority: 'medium',
          schedule: '0 2 * * *',
          retryPolicy: {
            maxRetries: 3,
            backoffStrategy: 'exponential'
          }
        };
        
        const response = await request(app)
          .post('/api/jobs')
          .send(jobData)
          .expect(201);
        
        expect(response.body).toHaveProperty('id');
        expect(response.body.name).toBe(jobData.name);
      });
    });

    describe('GET /api/jobs/:id', () => {
      it('should return specific job', async () => {
        const response = await request(app)
          .get('/api/jobs/test-job-123')
          .expect(200);
        
        expect(response.body).toHaveProperty('id');
        expect(response.body.id).toBe('test-job-123');
      });
    });

    describe('PUT /api/jobs/:id', () => {
      it('should update existing job', async () => {
        const updateData = {
          name: 'Updated Job',
          priority: 'high'
        };
        
        const response = await request(app)
          .put('/api/jobs/test-job-123')
          .send(updateData)
          .expect(200);
        
        expect(response.body.name).toBe(updateData.name);
        expect(response.body.priority).toBe(updateData.priority);
      });
    });

    describe('DELETE /api/jobs/:id', () => {
      it('should delete existing job', async () => {
        const response = await request(app)
          .delete('/api/jobs/test-job-123')
          .expect(200);
        
        expect(response.body).toHaveProperty('message');
        expect(response.body.message).toBe('Job deleted successfully');
      });
    });
  });

  describe('Error Handling', () => {
    it('should handle 404 for non-existent endpoints', async () => {
      const response = await request(app)
          .get('/api/nonexistent')
          .expect(404);
        
        expect(response.body).toHaveProperty('error');
      });
    });

    it('should handle 500 for server errors', async () => {
      // Mock a server error
      jest.spyOn(app, 'use').mockImplementation(() => {
        throw new Error('Internal server error');
      });
      
      const response = await request(app)
          .get('/api/jobs')
          .expect(500);
        
      expect(response.body).toHaveProperty('error');
    });
  });
});
