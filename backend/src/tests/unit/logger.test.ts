/**
 * Logger Unit Tests
 * 
 * Tests for the Logger utility class
 * 
 * @author AutoMind Team
 * @version 1.0.0
 */

import { Logger, LogLevel } from '../../utils/logger';

describe('Logger', () => {
  let logger: Logger;
  let consoleSpy: jest.SpyInstance;

  beforeEach(() => {
    logger = new Logger('TestLogger', LogLevel.DEBUG);
    consoleSpy = jest.spyOn(console, 'info').mockImplementation();
  });

  afterEach(() => {
    consoleSpy.mockRestore();
  });

  describe('constructor', () => {
    test('should create logger with default INFO level', () => {
      const defaultLogger = new Logger('DefaultLogger');
      expect(defaultLogger).toBeDefined();
    });

    test('should create logger with custom log level', () => {
      const debugLogger = new Logger('DebugLogger', LogLevel.DEBUG);
      expect(debugLogger).toBeDefined();
    });

    test('should accept context string', () => {
      const contextLogger = new Logger('ContextLogger');
      expect(contextLogger).toBeDefined();
    });
  });

  describe('log methods', () => {
    test('should log debug messages when level is DEBUG', () => {
      const debugSpy = jest.spyOn(console, 'debug').mockImplementation();
      logger.debug('Test debug message');
      expect(debugSpy).toHaveBeenCalled();
      debugSpy.mockRestore();
    });

    test('should log info messages', () => {
      const infoSpy = jest.spyOn(console, 'info').mockImplementation();
      logger.info('Test info message');
      expect(infoSpy).toHaveBeenCalledWith(
        expect.stringContaining('[INFO] [TestLogger] Test info message')
      );
      infoSpy.mockRestore();
    });

    test('should log warning messages', () => {
      const warnSpy = jest.spyOn(console, 'warn').mockImplementation();
      logger.warn('Test warning message');
      expect(warnSpy).toHaveBeenCalled();
      warnSpy.mockRestore();
    });

    test('should log error messages', () => {
      const errorSpy = jest.spyOn(console, 'error').mockImplementation();
      logger.error('Test error message');
      expect(errorSpy).toHaveBeenCalled();
      errorSpy.mockRestore();
    });

    test('should format messages with timestamp and context', () => {
      const debugSpy = jest.spyOn(console, 'debug').mockImplementation();
      logger.debug('Test message');
      expect(debugSpy).toHaveBeenCalledWith(
        expect.stringMatching(/\[\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z\] \[DEBUG\] \[TestLogger\] Test message/)
      );
      debugSpy.mockRestore();
    });

    test('should handle multiple arguments', () => {
      const debugSpy = jest.spyOn(console, 'debug').mockImplementation();
      logger.debug('Test message', { key: 'value' }, 123);
      expect(debugSpy).toHaveBeenCalledWith(
        expect.stringContaining('Test message {"key":"value"} 123')
      );
      debugSpy.mockRestore();
    });
  });

  describe('log level filtering', () => {
    test('should filter debug messages when level is INFO', () => {
      const infoLogger = new Logger('InfoLogger', LogLevel.INFO);
      const debugSpy = jest.spyOn(console, 'debug').mockImplementation();
      
      infoLogger.debug('This should not appear');
      expect(debugSpy).not.toHaveBeenCalled();
      
      debugSpy.mockRestore();
    });

    test('should filter info messages when level is WARN', () => {
      const warnLogger = new Logger('WarnLogger', LogLevel.WARN);
      const infoSpy = jest.spyOn(console, 'info').mockImplementation();
      
      warnLogger.info('This should not appear');
      expect(infoSpy).not.toHaveBeenCalled();
      
      infoSpy.mockRestore();
    });

    test('should allow error messages at all levels', () => {
      const errorLogger = new Logger('ErrorLogger', LogLevel.ERROR);
      const errorSpy = jest.spyOn(console, 'error').mockImplementation();
      
      errorLogger.error('This should appear');
      expect(errorSpy).toHaveBeenCalled();
      
      errorSpy.mockRestore();
    });
  });

  describe('setLogLevel', () => {
    test('should change log level', () => {
      const debugSpy = jest.spyOn(console, 'debug').mockImplementation();
      
      logger.setLogLevel(LogLevel.ERROR);
      logger.debug('This should not appear');
      expect(debugSpy).not.toHaveBeenCalled();
      
      logger.setLogLevel(LogLevel.DEBUG);
      logger.debug('This should appear');
      expect(debugSpy).toHaveBeenCalled();
      
      debugSpy.mockRestore();
    });
  });

  describe('LogLevel enum', () => {
    test('should have correct values', () => {
      expect(LogLevel.DEBUG).toBe(0);
      expect(LogLevel.INFO).toBe(1);
      expect(LogLevel.WARN).toBe(2);
      expect(LogLevel.ERROR).toBe(3);
    });
  });
});
