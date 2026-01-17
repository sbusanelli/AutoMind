/**
 * @jest-environment node
 */

// Mock dependencies
const mockLogger = {
  info: jest.fn(),
  error: jest.fn(),
  warn: jest.fn(),
  debug: jest.fn()
};

const mockCrypto = {
  createHash: jest.fn(() => ({
    update: jest.fn().mockReturnThis(),
    digest: jest.fn().mockReturnValue('mock-hash')
  }))
};

const mockFetch = jest.fn();

// Mock modules
jest.mock('../../utils/logger', () => mockLogger);
jest.mock('crypto', () => mockCrypto);
(global as any).fetch = mockFetch;

import { VaultService } from '../../services/vaultService';

describe('VaultService', () => {
  let vaultService: VaultService;

  beforeEach(() => {
    vaultService = new VaultService({
      url: 'https://vault.example.com',
      token: 'test-token'
    });
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('readSecret', () => {
    it('should read a secret from vault', async () => {
      const mockSecret = 'test-secret-value';
      
      // Mock process.env
      const originalEnv = process.env;
      process.env = {
        ...originalEnv,
        'VAULT_SECRET_PATH': mockSecret
      };
      
      const result = await vaultService.readSecret('vault/secret/path');
      
      expect(result).toBe(mockSecret);
      
      // Restore original env
      process.env = originalEnv;
    });

    it('should handle missing secret gracefully', async () => {
      const originalEnv = process.env;
      process.env = { ...process.env };
      
      await expect(vaultService.readSecret('nonexistent/path')).rejects.toThrow('Secret not found');
      
      process.env = originalEnv;
    });
  });

  describe('writeSecret', () => {
    it('should write a secret to vault', async () => {
      await expect(vaultService.writeSecret('test/secret/path', 'new-secret-value')).resolves.not.toThrow();
    });
  });

  describe('getAWSCredentials', () => {
    it('should return AWS credentials with defaults', async () => {
      const originalEnv = process.env;
      process.env = {
        ...originalEnv,
        'VAULT_AWS_ACCESS_KEY_ID': 'AKIAIOSFODNN7EXAMPLE',
        'VAULT_AWS_SECRET_ACCESS_KEY': 'very-long-secret-key-that-should-be-masked',
        'VAULT_AWS_REGION': 'us-west-2'
      };
      
      const result = await vaultService.getAWSCredentials();
      
      expect(result.accessKeyId).toBe('AKIAIOSFODNN7EXAMPLE');
      expect(result.secretAccessKey).toBe('very-long-secret-key-that-should-be-masked');
      expect(result.region).toBe('us-west-2');
      
      process.env = originalEnv;
    });
  });

  describe('getGCPCredentials', () => {
    it('should return GCP credentials with defaults', async () => {
      const originalEnv = process.env;
      process.env = {
        ...originalEnv,
        'VAULT_GCP_SERVICE_ACCOUNT_KEY': JSON.stringify({
          type: 'service_account',
          project_id: 'test-project',
          private_key_id: 'test-key-id',
          private_key: 'test-private-key'
        }),
        'VAULT_GCP_PROJECT_ID': 'test-project',
        'VAULT_GCP_REGION': 'us-central1'
      };
      
      const result = await vaultService.getGCPCredentials();
      
      expect(result.projectId).toBe('test-project');
      expect(result.region).toBe('us-central1');
      
      process.env = originalEnv;
    });
  });

  describe('getAzureCredentials', () => {
    it('should return Azure credentials with defaults', async () => {
      const originalEnv = process.env;
      process.env = {
        ...originalEnv,
        'VAULT_AZURE_CLIENT_ID': 'test-client-id',
        'VAULT_AZURE_CLIENT_SECRET': 'test-client-secret',
        'VAULT_AZURE_TENANT_ID': 'test-tenant-id',
        'VAULT_AZURE_SUBSCRIPTION_ID': 'test-subscription-id'
      };
      
      const result = await vaultService.getAzureCredentials();
      
      expect(result.clientId).toBe('test-client-id');
      expect(result.clientSecret).toBe('test-client-secret');
      expect(result.tenantId).toBe('test-tenant-id');
      expect(result.subscriptionId).toBe('test-subscription-id');
      
      process.env = originalEnv;
    });
  });

  describe('getGitHubCredentials', () => {
    it('should return GitHub credentials', async () => {
      const originalEnv = process.env;
      process.env = {
        ...originalEnv,
        'VAULT_GITHUB_TOKEN': 'ghp_test-token',
        'VAULT_GITHUB_USERNAME': 'test-username'
      };
      
      const result = await vaultService.getGitHubCredentials();
      
      expect(result.token).toBe('ghp_test-token');
      expect(result.username).toBe('test-username');
      
      process.env = originalEnv;
    });
  });

  describe('getOpenAICredentials', () => {
    it('should return OpenAI credentials', async () => {
      const originalEnv = process.env;
      process.env = {
        ...originalEnv,
        'VAULT_OPENAI_API_KEY': 'sk-test-openai-key'
      };
      
      const result = await vaultService.getOpenAICredentials();
      
      expect(result.apiKey).toBe('sk-test-openai-key');
      
      process.env = originalEnv;
    });
  });

  describe('getSlackWebhook', () => {
    it('should return Slack webhook URL', async () => {
      const originalEnv = process.env;
      process.env = {
        ...originalEnv,
        'VAULT_SLACK_WEBHOOK_URL': 'https://hooks.slack.com/test'
      };
      
      const result = await vaultService.getSlackWebhook();
      
      expect(result).toBe('https://hooks.slack.com/test');
      
      process.env = originalEnv;
    });
  });

  describe('rotateSecret', () => {
    it('should rotate a secret successfully', async () => {
      const originalEnv = process.env;
      process.env = {
        ...originalEnv,
        'VAULT_SECRET_PATH': 'old-secret-value'
      };
      
      await expect(vaultService.rotateSecret('test/secret/path', 'new-secret-value')).resolves.not.toThrow();
      
      process.env = originalEnv;
    });
  });

  describe('secretExists', () => {
    it('should return true for existing secret', async () => {
      const originalEnv = process.env;
      process.env = {
        ...originalEnv,
        'VAULT_SECRET_PATH': 'test-secret-value'
      };
      
      const result = await vaultService.secretExists('test/secret/path');
      
      expect(result).toBe(true);
      
      process.env = originalEnv;
    });

    it('should return false for non-existing secret', async () => {
      const originalEnv = process.env;
      process.env = { ...process.env };
      
      const result = await vaultService.secretExists('nonexistent/path');
      
      expect(result).toBe(false);
      
      process.env = originalEnv;
    });
  });

  describe('getSecretWithRotation', () => {
    it('should get secret and check rotation age', async () => {
      const originalEnv = process.env;
      process.env = {
        ...originalEnv,
        'VAULT_SECRET_PATH': 'test-secret-value'
      };
      
      const result = await vaultService.getSecretWithRotation('test/secret/path');
      
      expect(result).toBe('test-secret-value');
      
      process.env = originalEnv;
    });
  });

  describe('initializeEnvironment', () => {
    it('should initialize environment from vault', async () => {
      const originalEnv = process.env;
      process.env = { ...process.env };
      
      await vaultService.initializeEnvironment();
      
      // Check that environment variables are set
      expect(process.env.AWS_ACCESS_KEY_ID).toBeDefined();
      expect(process.env.AWS_SECRET_ACCESS_KEY).toBeDefined();
      expect(process.env.GCP_SERVICE_ACCOUNT_KEY).toBeDefined();
      expect(process.env.GCP_PROJECT_ID).toBeDefined();
      expect(process.env.AZURE_CLIENT_ID).toBeDefined();
      expect(process.env.AZURE_CLIENT_SECRET).toBeDefined();
      expect(process.env.AZURE_TENANT_ID).toBeDefined();
      expect(process.env.AZURE_SUBSCRIPTION_ID).toBeDefined();
      expect(process.env.GITHUB_TOKEN).toBeDefined();
      expect(process.env.GITHUB_USERNAME).toBeDefined();
      expect(process.env.OPENAI_API_KEY).toBeDefined();
      expect(process.env.SLACK_WEBHOOK_URL).toBeDefined();
      
      process.env = originalEnv;
    });
  });

  describe('healthCheck', () => {
    it('should return true for healthy vault connection', async () => {
      const originalEnv = process.env;
      process.env = {
        ...originalEnv,
        'VAULT_HEALTH_CHECK': 'healthy'
      };
      
      const result = await vaultService.healthCheck();
      
      expect(result).toBe(true);
      
      process.env = originalEnv;
    });

    it('should return false for unhealthy vault connection', async () => {
      const originalEnv = process.env;
      process.env = { ...process.env };
      
      const result = await vaultService.healthCheck();
      
      expect(result).toBe(false);
      
      process.env = originalEnv;
    });
  });
});
