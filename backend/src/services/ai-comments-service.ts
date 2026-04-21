/**
 * AI Comments Service for AutoMind Dashboard
 * Provides AI-powered comment generation and analysis
 */

import { Logger } from '../utils/logger';

export interface AIComment {
  id: string;
  author: string;
  content: string;
  timestamp: Date;
  sentiment: 'positive' | 'neutral' | 'negative';
  category: 'insight' | 'recommendation' | 'warning' | 'question' | 'achievement';
  priority: 'low' | 'medium' | 'high';
  isAI: boolean;
  metadata?: {
    confidence?: number;
    relatedMetrics?: string[];
    actionItems?: string[];
  };
}

export interface CommentGenerationRequest {
  context: string;
  metrics?: Record<string, any>;
  userAction?: string;
  sentiment?: 'positive' | 'neutral' | 'negative';
  category?: 'insight' | 'recommendation' | 'warning' | 'question' | 'achievement';
  priority?: 'low' | 'medium' | 'high';
}

export interface CommentAnalysisResult {
  sentiment: 'positive' | 'neutral' | 'negative';
  category: 'insight' | 'recommendation' | 'warning' | 'question' | 'achievement';
  priority: 'low' | 'medium' | 'high';
  confidence: number;
  keywords: string[];
  actionItems: string[];
}

export class AICommentsService {
  private logger: Logger;
  private comments: AIComment[] = [];
  private readonly maxComments = 50;

  constructor() {
    this.logger = new Logger('AICommentsService');
    this.initializeSampleComments();
  }

  /**
   * Generate AI-powered comment based on context and metrics
   */
  async generateComment(request: CommentGenerationRequest): Promise<AIComment> {
    try {
      const analysis = await this.analyzeContext(request);
      const content = await this.generateCommentContent(request, analysis);
      
      const comment: AIComment = {
        id: this.generateId(),
        author: 'AutoMind AI',
        content,
        timestamp: new Date(),
        sentiment: analysis.sentiment,
        category: analysis.category,
        priority: analysis.priority,
        isAI: true,
        metadata: {
          confidence: analysis.confidence,
          relatedMetrics: this.extractRelatedMetrics(request.metrics),
          actionItems: analysis.actionItems
        }
      };

      this.addComment(comment);
      this.logger.info(`Generated AI comment: ${comment.category} - ${comment.sentiment}`);
      
      return comment;
    } catch (error) {
      this.logger.error('Failed to generate AI comment', error);
      throw error;
    }
  }

  /**
   * Add user comment to the system
   */
  addUserComment(content: string, author: string = 'User'): AIComment {
    const analysis = this.analyzeText(content);
    
    const comment: AIComment = {
      id: this.generateId(),
      author,
      content,
      timestamp: new Date(),
      sentiment: analysis.sentiment,
      category: analysis.category,
      priority: analysis.priority,
      isAI: false
    };

    this.addComment(comment);
    this.logger.info(`Added user comment from ${author}`);
    
    return comment;
  }

  /**
   * Get all comments with optional filtering
   */
  getComments(filters?: {
    category?: string;
    sentiment?: string;
    priority?: string;
    isAI?: boolean;
    limit?: number;
  }): AIComment[] {
    let filtered = [...this.comments];

    if (filters) {
      if (filters.category) {
        filtered = filtered.filter(c => c.category === filters.category);
      }
      if (filters.sentiment) {
        filtered = filtered.filter(c => c.sentiment === filters.sentiment);
      }
      if (filters.priority) {
        filtered = filtered.filter(c => c.priority === filters.priority);
      }
      if (filters.isAI !== undefined) {
        filtered = filtered.filter(c => c.isAI === filters.isAI);
      }
    }

    // Sort by timestamp (newest first) and apply limit
    filtered.sort((a, b) => b.timestamp.getTime() - a.timestamp.getTime());
    
    if (filters?.limit) {
      filtered = filtered.slice(0, filters.limit);
    }

    return filtered;
  }

  /**
   * Delete comment by ID
   */
  deleteComment(id: string): boolean {
    const index = this.comments.findIndex(c => c.id === id);
    if (index !== -1) {
      this.comments.splice(index, 1);
      this.logger.info(`Deleted comment: ${id}`);
      return true;
    }
    return false;
  }

  /**
   * Get comment statistics
   */
  getStatistics() {
    const stats = {
      total: this.comments.length,
      aiGenerated: this.comments.filter(c => c.isAI).length,
      userComments: this.comments.filter(c => !c.isAI).length,
      byCategory: {} as Record<string, number>,
      bySentiment: {} as Record<string, number>,
      byPriority: {} as Record<string, number>
    };

    this.comments.forEach(comment => {
      stats.byCategory[comment.category] = (stats.byCategory[comment.category] || 0) + 1;
      stats.bySentiment[comment.sentiment] = (stats.bySentiment[comment.sentiment] || 0) + 1;
      stats.byPriority[comment.priority] = (stats.byPriority[comment.priority] || 0) + 1;
    });

    return stats;
  }

  /**
   * Analyze context for comment generation
   */
  private async analyzeContext(request: CommentGenerationRequest): Promise<CommentAnalysisResult> {
    // Simulate AI analysis (in production, this would call actual AI service)
    const text = request.context + ' ' + JSON.stringify(request.metrics || {});
    
    // Simple keyword-based analysis (replace with actual AI in production)
    const keywords = this.extractKeywords(text);
    const sentiment = this.determineSentiment(text, request.sentiment);
    const category = this.determineCategory(text, request.category);
    const priority = this.determinePriority(text, request.priority);
    const actionItems = this.extractActionItems(text);

    return {
      sentiment,
      category,
      priority,
      confidence: 0.85 + Math.random() * 0.15, // Simulated confidence
      keywords,
      actionItems
    };
  }

  /**
   * Generate comment content based on analysis
   */
  private async generateCommentContent(request: CommentGenerationRequest, analysis: CommentAnalysisResult): Promise<string> {
    const templates = this.getCommentTemplates(analysis.category, analysis.sentiment);
    const template = templates[Math.floor(Math.random() * templates.length)];
    
    // Replace placeholders with actual values
    let content = template;
    
    if (request.metrics) {
      const metricNames = Object.keys(request.metrics);
      if (metricNames.length > 0) {
        const metric = metricNames[0];
        const value = request.metrics[metric];
        content = content.replace('{metric}', metric).replace('{value}', String(value));
      }
    }

    if (request.userAction) {
      content = content.replace('{action}', request.userAction);
    }

    content = content.replace('{keywords}', analysis.keywords.join(', '));
    
    return content;
  }

  /**
   * Analyze text for sentiment, category, and priority
   */
  private analyzeText(text: string): CommentAnalysisResult {
    const keywords = this.extractKeywords(text);
    const sentiment = this.determineSentiment(text);
    const category = this.determineCategory(text);
    const priority = this.determinePriority(text);
    const actionItems = this.extractActionItems(text);

    return {
      sentiment,
      category,
      priority,
      confidence: 0.8,
      keywords,
      actionItems
    };
  }

  /**
   * Extract keywords from text
   */
  private extractKeywords(text: string): string[] {
    const words = text.toLowerCase().split(/\s+/);
    const stopWords = new Set(['the', 'is', 'at', 'which', 'on', 'and', 'a', 'an', 'as', 'are', 'was', 'were', 'been', 'be']);
    
    return words
      .filter(word => word.length > 3 && !stopWords.has(word))
      .slice(0, 5);
  }

  /**
   * Determine sentiment based on text and keywords
   */
  private determineSentiment(text: string, override?: 'positive' | 'neutral' | 'negative'): 'positive' | 'neutral' | 'negative' {
    if (override) return override;

    const positiveWords = ['good', 'great', 'excellent', 'improved', 'success', 'achievement', 'optimal'];
    const negativeWords = ['bad', 'poor', 'failed', 'error', 'issue', 'problem', 'warning', 'critical'];
    
    const lowerText = text.toLowerCase();
    
    if (positiveWords.some(word => lowerText.includes(word))) return 'positive';
    if (negativeWords.some(word => lowerText.includes(word))) return 'negative';
    
    return 'neutral';
  }

  /**
   * Determine category based on content
   */
  private determineCategory(text: string, override?: 'insight' | 'recommendation' | 'warning' | 'question' | 'achievement'): 'insight' | 'recommendation' | 'warning' | 'question' | 'achievement' {
    if (override) return override;

    const lowerText = text.toLowerCase();
    
    if (lowerText.includes('warning') || lowerText.includes('error') || lowerText.includes('critical')) return 'warning';
    if (lowerText.includes('recommend') || lowerText.includes('suggest') || lowerText.includes('should')) return 'recommendation';
    if (lowerText.includes('achieve') || lowerText.includes('success') || lowerText.includes('complete')) return 'achievement';
    if (lowerText.includes('?') || lowerText.includes('how') || lowerText.includes('what')) return 'question';
    
    return 'insight';
  }

  /**
   * Determine priority based on content
   */
  private determinePriority(text: string, override?: 'low' | 'medium' | 'high'): 'low' | 'medium' | 'high' {
    if (override) return override;

    const lowerText = text.toLowerCase();
    
    if (lowerText.includes('critical') || lowerText.includes('urgent') || lowerText.includes('error')) return 'high';
    if (lowerText.includes('important') || lowerText.includes('recommend') || lowerText.includes('should')) return 'medium';
    
    return 'low';
  }

  /**
   * Extract action items from text
   */
  private extractActionItems(text: string): string[] {
    const actionRegex = /(should|need to|must|consider|implement|fix|resolve|optimize|improve)\s+([^.!?]+)/gi;
    const matches = text.match(actionRegex);
    
    return matches ? matches.slice(0, 3) : [];
  }

  /**
   * Extract related metrics from metrics object
   */
  private extractRelatedMetrics(metrics?: Record<string, any>): string[] {
    if (!metrics) return [];
    
    return Object.keys(metrics).slice(0, 3);
  }

  /**
   * Get comment templates based on category and sentiment
   */
  private getCommentTemplates(category: string, sentiment: string): string[] {
    const templates: Record<string, Record<string, string[]>> = {
      insight: {
        positive: [
          "Great insight! I've noticed that {metric} is performing well at {value}. This indicates positive system health.",
          "Interesting pattern detected in {keywords}. The current metrics show optimal performance.",
          "Based on the data, system behavior is following expected patterns with {metric} at {value}."
        ],
        neutral: [
          "Observing {metric} at {value}. This falls within normal operational parameters.",
          "System metrics show {keywords}. No anomalies detected in current operations.",
          "Current status indicates {metric} is stable at {value}. Monitoring continues."
        ],
        negative: [
          "Noticing unusual patterns in {keywords}. {metric} at {value} requires attention.",
          "System behavior deviates from expected norms. Investigating {metric} readings.",
          "Alert: {metric} showing {value} which is outside normal range."
        ]
      },
      recommendation: {
        positive: [
          "Excellent performance! Consider maintaining current configuration for {metric}.",
          "System is running optimally. Recommend documenting current settings for {keywords}.",
          "Great results with {metric} at {value}. Consider this as baseline for future comparisons."
        ],
        neutral: [
          "Recommend reviewing {metric} settings. Current value of {value} could be optimized.",
          "Consider implementing automated monitoring for {keywords}.",
          "Suggestion: Set up alerts for {metric} when it deviates from {value}."
        ],
        negative: [
          "Immediate action required: {metric} at {value} needs optimization.",
          "Critical recommendation: Address {keywords} issues to prevent system degradation.",
          "Urgent: Implement fixes for {metric} to restore normal operations."
        ]
      },
      warning: {
        positive: [],
        neutral: [
          "Warning: {metric} approaching threshold. Current value: {value}.",
          "Caution: Monitor {keywords} closely for potential issues.",
          "Alert: {metric} showing unusual patterns at {value}."
        ],
        negative: [
          "Critical warning: {metric} at {value} requires immediate attention!",
          "System alert: {keywords} indicate potential failure. Take action now!",
          "Urgent warning: {metric} has reached critical levels at {value}!"
        ]
      },
      achievement: {
        positive: [
          "Congratulations! {metric} achieved excellent results at {value}!",
          "Outstanding performance: {keywords} targets exceeded!",
          "Great achievement: System optimization completed with {metric} at {value}!"
        ],
        neutral: [
          "Target achieved: {metric} reached {value}.",
          "Milestone completed: {keywords} objectives met.",
          "Goal accomplished: {metric} performance at {value}."
        ],
        negative: []
      },
      question: {
        positive: [
          "How did we achieve {metric} at {value}? This success could be replicated elsewhere.",
          "What factors contributed to the positive {keywords} results?",
          "Can we maintain {metric} at {value} long-term?"
        ],
        neutral: [
          "What is causing {metric} to be at {value}?",
          "How should we interpret the {keywords} data?",
          "Why is {metric} showing this pattern?"
        ],
        negative: [
          "Why is {metric} performing poorly at {value}?",
          "What are the root causes of the {keywords} issues?",
          "How can we fix the {metric} problems?"
        ]
      }
    };

    return templates[category]?.[sentiment] || templates.insight.neutral;
  }

  /**
   * Add comment to storage (maintain max limit)
   */
  private addComment(comment: AIComment): void {
    this.comments.unshift(comment);
    
    // Maintain maximum comment limit
    if (this.comments.length > this.maxComments) {
      this.comments = this.comments.slice(0, this.maxComments);
    }
  }

  /**
   * Generate unique ID for comments
   */
  private generateId(): string {
    return `comment_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * Initialize with sample comments
   */
  private initializeSampleComments(): void {
    const sampleComments: AIComment[] = [
      {
        id: this.generateId(),
        author: 'AutoMind AI',
        content: 'System optimization completed successfully! Memory usage reduced by 23% and performance improved by 15%.',
        timestamp: new Date(Date.now() - 300000),
        sentiment: 'positive',
        category: 'achievement',
        priority: 'high',
        isAI: true,
        metadata: {
          confidence: 0.92,
          relatedMetrics: ['memory', 'performance'],
          actionItems: ['Monitor system stability', 'Document optimization results']
        }
      },
      {
        id: this.generateId(),
        author: 'AutoMind AI',
        content: 'Noticing unusual CPU spike patterns. Recommend investigating potential memory leaks in the application.',
        timestamp: new Date(Date.now() - 600000),
        sentiment: 'neutral',
        category: 'recommendation',
        priority: 'medium',
        isAI: true,
        metadata: {
          confidence: 0.87,
          relatedMetrics: ['cpu', 'memory'],
          actionItems: ['Investigate CPU patterns', 'Check for memory leaks']
        }
      },
      {
        id: this.generateId(),
        author: 'User',
        content: 'The dashboard is much more responsive after the recent optimizations!',
        timestamp: new Date(Date.now() - 900000),
        sentiment: 'positive',
        category: 'insight',
        priority: 'low',
        isAI: false
      }
    ];

    this.comments = sampleComments;
  }
}

// Singleton instance
export const aiCommentsService = new AICommentsService();
