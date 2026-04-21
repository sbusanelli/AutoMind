/**
 * API Routes for AI Comments Service
 */

import express from 'express';
import { aiCommentsService, AIComment, CommentGenerationRequest } from '../services/ai-comments-service';

const router = express.Router();

/**
 * GET /api/comments
 * Get all comments with optional filtering
 */
router.get('/', (req, res) => {
  try {
    const filters = {
      category: req.query.category as string,
      sentiment: req.query.sentiment as string,
      priority: req.query.priority as string,
      isAI: req.query.isAI === 'true' ? true : req.query.isAI === 'false' ? false : undefined,
      limit: req.query.limit ? parseInt(req.query.limit as string) : undefined
    };

    const comments = aiCommentsService.getComments(filters);
    res.json({
      success: true,
      data: comments,
      total: comments.length
    });
  } catch (error) {
    console.error('Error fetching comments:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch comments'
    });
  }
});

/**
 * GET /api/comments/:id
 * Get specific comment by ID
 */
router.get('/:id', (req, res) => {
  try {
    const comments = aiCommentsService.getComments();
    const comment = comments.find(c => c.id === req.params.id);
    
    if (!comment) {
      return res.status(404).json({
        success: false,
        error: 'Comment not found'
      });
    }

    res.json({
      success: true,
      data: comment
    });
  } catch (error) {
    console.error('Error fetching comment:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch comment'
    });
  }
});

/**
 * POST /api/comments/generate
 * Generate AI-powered comment
 */
router.post('/generate', async (req, res) => {
  try {
    const request: CommentGenerationRequest = req.body;
    
    if (!request.context) {
      return res.status(400).json({
        success: false,
        error: 'Context is required for comment generation'
      });
    }

    const comment = await aiCommentsService.generateComment(request);
    
    res.json({
      success: true,
      data: comment,
      message: 'AI comment generated successfully'
    });
  } catch (error) {
    console.error('Error generating comment:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to generate AI comment'
    });
  }
});

/**
 * POST /api/comments
 * Add user comment
 */
router.post('/', (req, res) => {
  try {
    const { content, author } = req.body;
    
    if (!content) {
      return res.status(400).json({
        success: false,
        error: 'Comment content is required'
      });
    }

    const comment = aiCommentsService.addUserComment(content, author);
    
    res.json({
      success: true,
      data: comment,
      message: 'Comment added successfully'
    });
  } catch (error) {
    console.error('Error adding comment:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to add comment'
    });
  }
});

/**
 * DELETE /api/comments/:id
 * Delete comment by ID
 */
router.delete('/:id', (req, res) => {
  try {
    const deleted = aiCommentsService.deleteComment(req.params.id);
    
    if (!deleted) {
      return res.status(404).json({
        success: false,
        error: 'Comment not found'
      });
    }

    res.json({
      success: true,
      message: 'Comment deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting comment:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to delete comment'
    });
  }
});

/**
 * GET /api/comments/statistics
 * Get comment statistics
 */
router.get('/statistics', (req, res) => {
  try {
    const stats = aiCommentsService.getStatistics();
    res.json({
      success: true,
      data: stats
    });
  } catch (error) {
    console.error('Error fetching statistics:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch statistics'
    });
  }
});

/**
 * POST /api/comments/batch
 * Generate multiple AI comments for different contexts
 */
router.post('/batch', async (req, res) => {
  try {
    const { contexts } = req.body;
    
    if (!Array.isArray(contexts) || contexts.length === 0) {
      return res.status(400).json({
        success: false,
        error: 'Contexts array is required'
      });
    }

    const comments = [];
    for (const context of contexts) {
      try {
        const comment = await aiCommentsService.generateComment(context);
        comments.push(comment);
      } catch (error) {
        console.error('Error generating comment for context:', context, error);
        // Continue with other contexts even if one fails
      }
    }

    res.json({
      success: true,
      data: comments,
      message: `Generated ${comments.length} AI comments`
    });
  } catch (error) {
    console.error('Error generating batch comments:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to generate batch comments'
    });
  }
});

/**
 * POST /api/comments/analyze
 * Analyze text for sentiment, category, and priority
 */
router.post('/analyze', (req, res) => {
  try {
    const { text } = req.body;
    
    if (!text) {
      return res.status(400).json({
        success: false,
        error: 'Text is required for analysis'
      });
    }

    // This would use the internal analysis method
    // For now, we'll simulate the analysis
    const analysis = {
      sentiment: 'neutral',
      category: 'insight',
      priority: 'medium',
      confidence: 0.85,
      keywords: text.split(' ').slice(0, 5),
      actionItems: []
    };

    res.json({
      success: true,
      data: analysis
    });
  } catch (error) {
    console.error('Error analyzing text:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to analyze text'
    });
  }
});

export default router;
