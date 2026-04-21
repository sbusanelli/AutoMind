/**
 * TurboQuant Configuration Module
 * 
 * Configuration management for TurboQuant integration
 * Environment-specific settings and defaults
 * 
 * @author AutoMind Team
 * @version 1.0.0
 */

import { TurboQuantConfig } from './index';

export interface TurboQuantEnvironmentConfig {
  development: TurboQuantConfig;
  staging: TurboQuantConfig;
  production: TurboQuantConfig;
}

export const DEFAULT_CONFIG: TurboQuantEnvironmentConfig = {
  development: {
    bitWidth: 4, // Higher bit width for development accuracy
    enablePolarQuant: true,
    enableQJL: true,
    batchSize: 16, // Smaller batches for development
    maxSequenceLength: 4096, // Smaller context for development
    enableGPUAcceleration: false, // Disable GPU for development
    compressionRatio: 4, // Conservative compression for development
    enableMemoryPool: true,
    maxMemoryUsage: 512 // 512MB for development
  },
  staging: {
    bitWidth: 3,
    enablePolarQuant: true,
    enableQJL: true,
    batchSize: 32,
    maxSequenceLength: 8192,
    enableGPUAcceleration: true,
    compressionRatio: 6, // Target compression ratio
    enableMemoryPool: true,
    maxMemoryUsage: 1024 // 1GB for staging
  },
  production: {
    bitWidth: 3, // Maximum compression for production
    enablePolarQuant: true,
    enableQJL: true,
    batchSize: 64, // Larger batches for production efficiency
    maxSequenceLength: 16384, // Maximum context length
    enableGPUAcceleration: true,
    compressionRatio: 6, // Target compression ratio
    enableMemoryPool: true,
    maxMemoryUsage: 2048 // 2GB for production
  }
};

/**
 * Get configuration based on environment
 */
export function getTurboQuantConfig(environment?: string): TurboQuantConfig {
  const env = environment || process.env.NODE_ENV || 'development';
  
  switch (env) {
    case 'production':
      return { ...DEFAULT_CONFIG.production };
    case 'staging':
      return { ...DEFAULT_CONFIG.staging };
    case 'development':
    default:
      return { ...DEFAULT_CONFIG.development };
  }
}

/**
 * Validate TurboQuant configuration
 */
export function validateConfig(config: Partial<TurboQuantConfig>): {
  isValid: boolean;
  errors: string[];
  warnings: string[];
} {
  const errors: string[] = [];
  const warnings: string[] = [];

  // Validate bit width
  if (config.bitWidth && ![3, 4, 8].includes(config.bitWidth)) {
    errors.push('bitWidth must be 3, 4, or 8');
  }

  // Validate batch size
  if (config.batchSize && (config.batchSize < 1 || config.batchSize > 128)) {
    errors.push('batchSize must be between 1 and 128');
  }

  // Validate max sequence length
  if (config.maxSequenceLength && (config.maxSequenceLength < 512 || config.maxSequenceLength > 32768)) {
    errors.push('maxSequenceLength must be between 512 and 32768');
  }

  // Validate compression ratio
  if (config.compressionRatio && (config.compressionRatio < 1 || config.compressionRatio > 10)) {
    errors.push('compressionRatio must be between 1 and 10');
  }

  // Validate memory usage
  if (config.maxMemoryUsage && (config.maxMemoryUsage < 64 || config.maxMemoryUsage > 8192)) {
    errors.push('maxMemoryUsage must be between 64MB and 8GB');
  }

  // Warnings for suboptimal configurations
  if (config.bitWidth === 8) {
    warnings.push('bitWidth of 8 provides minimal compression benefits');
  }

  if (config.compressionRatio < 4) {
    warnings.push('compressionRatio below 4 may not provide significant memory savings');
  }

  if (config.enableGPUAcceleration === false && config.maxSequenceLength > 8192) {
    warnings.push('Large sequence lengths without GPU acceleration may be slow');
  }

  return {
    isValid: errors.length === 0,
    errors,
    warnings
  };
}

/**
 * Merge user configuration with defaults
 */
export function mergeConfig(
  userConfig: Partial<TurboQuantConfig>,
  environment?: string
): TurboQuantConfig {
  const baseConfig = getTurboQuantConfig(environment);
  const merged = { ...baseConfig, ...userConfig };
  
  // Ensure critical settings are preserved
  if (!userConfig.enablePolarQuant) {
    merged.enablePolarQuant = baseConfig.enablePolarQuant;
  }
  
  if (!userConfig.enableQJL) {
    merged.enableQJL = baseConfig.enableQJL;
  }
  
  return merged;
}

/**
 * Configuration for different use cases
 */
export const USE_CASE_CONFIGS = {
  documentProcessing: {
    bitWidth: 3 as const,
    enablePolarQuant: true,
    enableQJL: true,
    batchSize: 32,
    maxSequenceLength: 16384,
    enableGPUAcceleration: true,
    compressionRatio: 6,
    enableMemoryPool: true,
    maxMemoryUsage: 1024
  },
  
  realTimeChat: {
    bitWidth: 4 as const,
    enablePolarQuant: true,
    enableQJL: true,
    batchSize: 8,
    maxSequenceLength: 4096,
    enableGPUAcceleration: true,
    compressionRatio: 4,
    enableMemoryPool: true,
    maxMemoryUsage: 512
  },
  
  batchAnalysis: {
    bitWidth: 3 as const,
    enablePolarQuant: true,
    enableQJL: true,
    batchSize: 64,
    maxSequenceLength: 8192,
    enableGPUAcceleration: true,
    compressionRatio: 6,
    enableMemoryPool: true,
    maxMemoryUsage: 2048
  },
  
  edgeDeployment: {
    bitWidth: 4 as const,
    enablePolarQuant: true,
    enableQJL: false, // Disable QJL for edge devices
    batchSize: 16,
    maxSequenceLength: 2048,
    enableGPUAcceleration: false, // Usually no GPU on edge
    compressionRatio: 4,
    enableMemoryPool: true,
    maxMemoryUsage: 256
  }
};

/**
 * Get configuration for specific use case
 */
export function getUseCaseConfig(useCase: keyof typeof USE_CASE_CONFIGS): TurboQuantConfig {
  return { ...USE_CASE_CONFIGS[useCase] };
}

/**
 * Environment variables and their mappings
 */
export const ENV_VARIABLES = {
  TURBOQUANT_BIT_WIDTH: 'bitWidth',
  TURBOQUANT_ENABLE_GPU: 'enableGPUAcceleration',
  TURBOQUANT_BATCH_SIZE: 'batchSize',
  TURBOQUANT_MAX_SEQUENCE_LENGTH: 'maxSequenceLength',
  TURBOQUANT_COMPRESSION_RATIO: 'compressionRatio',
  TURBOQUANT_MAX_MEMORY_USAGE: 'maxMemoryUsage',
  TURBOQUANT_ENABLE_MEMORY_POOL: 'enableMemoryPool',
  TURBOQUANT_ENABLE_POLAR_QUANT: 'enablePolarQuant',
  TURBOQUANT_ENABLE_QJL: 'enableQJL'
} as const;

/**
 * Load configuration from environment variables
 */
export function loadConfigFromEnvironment(): Partial<TurboQuantConfig> {
  const config: Partial<TurboQuantConfig> = {};

  Object.entries(ENV_VARIABLES).forEach(([envVar, configKey]) => {
    const value = process.env[envVar];
    if (value !== undefined) {
      // Type conversion based on the config key
      switch (configKey) {
        case 'bitWidth':
          config[configKey] = parseInt(value, 10) as 3 | 4 | 8;
          break;
        case 'batchSize':
        case 'maxSequenceLength':
        case 'maxMemoryUsage':
          config[configKey] = parseInt(value, 10);
          break;
        case 'compressionRatio':
          config[configKey] = parseFloat(value);
          break;
        case 'enableGPUAcceleration':
        case 'enableMemoryPool':
        case 'enablePolarQuant':
        case 'enableQJL':
          config[configKey] = value.toLowerCase() === 'true';
          break;
      }
    }
  });

  return config;
}

/**
 * Complete configuration loading with validation
 */
export function loadAndValidateConfig(
  userConfig?: Partial<TurboQuantConfig>,
  environment?: string
): {
  config: TurboQuantConfig;
  validation: ReturnType<typeof validateConfig>;
} {
  // Load in order: defaults -> environment -> user config
  const envConfig = loadConfigFromEnvironment();
  const baseConfig = getTurboQuantConfig(environment);
  const mergedConfig = { ...baseConfig, ...envConfig, ...userConfig };
  
  // Validate final configuration
  const validation = validateConfig(mergedConfig);
  
  return {
    config: mergedConfig,
    validation
  };
}
