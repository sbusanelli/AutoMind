import React, { useState, useEffect } from 'react';
import { Send, Bot, Brain, TrendingUp, AlertTriangle } from 'lucide-react';

interface AIMessage {
  id: string;
  type: 'user' | 'assistant';
  content: string;
  timestamp: string;
  suggestions?: string[];
}

interface AIInsight {
  type: 'optimization' | 'prediction' | 'anomaly' | 'performance';
  title: string;
  description: string;
  value: string | number;
  trend?: 'up' | 'down' | 'stable';
  severity?: 'low' | 'medium' | 'high';
}

export const AIAssistant: React.FC = () => {
  const [messages, setMessages] = useState<AIMessage[]>([]);
  const [input, setInput] = useState('');
  const [isTyping, setIsTyping] = useState(false);
  const [insights, setInsights] = useState<AIInsight[]>([]);

  useEffect(() => {
    // Simulate AI insights
    const mockInsights: AIInsight[] = [
      {
        type: 'performance',
        title: 'System Efficiency',
        description: 'Overall system performance',
        value: 87,
        trend: 'up',
        severity: 'low'
      },
      {
        type: 'prediction',
        title: 'Job Failure Risk',
        description: 'Predicted failures in next 24h',
        value: 12,
        severity: 'medium'
      },
      {
        type: 'optimization',
        title: 'Resource Utilization',
        description: 'CPU and memory usage',
        value: 73,
        trend: 'stable',
        severity: 'low'
      }
    ];
    setInsights(mockInsights);
  }, []);

  const handleSend = async () => {
    if (!input.trim()) return;

    const userMessage: AIMessage = {
      id: Date.now().toString(),
      type: 'user',
      content: input,
      timestamp: new Date().toISOString()
    };

    setMessages(prev => [...prev, userMessage]);
    setInput('');
    setIsTyping(true);

    try {
      // Simulate AI response
      setTimeout(() => {
        const aiResponse: AIMessage = {
          id: (Date.now() + 1).toString(),
          type: 'assistant',
          content: generateAIResponse(input),
          timestamp: new Date().toISOString(),
          suggestions: generateSuggestions(input)
        };

        setMessages(prev => [...prev, aiResponse]);
        setIsTyping(false);
      }, 1500);
    } catch (error) {
      setIsTyping(false);
    }
  };

  const generateAIResponse = (query: string): string => {
    const responses: { [key: string]: string } = {
      'optimize': 'Based on current system metrics, I recommend scheduling high-priority jobs during off-peak hours and enabling auto-retry for failed jobs.',
      'performance': 'System performance is optimal. CPU usage at 45%, memory at 62%. Consider increasing job concurrency by 15% for better throughput.',
      'failure': 'The main cause of job failures appears to be resource contention. I suggest implementing resource quotas and adding more robust error handling.',
      'schedule': 'I\'ve analyzed your job dependencies and created an optimized schedule that reduces total execution time by 23% while eliminating resource conflicts.',
      'default': 'I can help you optimize job scheduling, analyze performance metrics, predict failures, and provide system insights. What would you like to know?'
    };

    // Simple keyword matching for demo
    for (const [key, response] of Object.entries(responses)) {
      if (query.toLowerCase().includes(key)) {
        return response;
      }
    }
    
    return responses.default;
  };

  const generateSuggestions = (query: string): string[] => {
    const suggestions = [
      'Run performance analysis on all jobs',
      'Check for resource bottlenecks',
      'Review job failure patterns',
      'Optimize job scheduling',
      'Enable AI-powered monitoring',
      'Review system logs'
    ];

    return suggestions.filter(s => 
      query.toLowerCase().includes('performance') && s.includes('performance') ||
      query.toLowerCase().includes('optimize') && s.includes('optimize') ||
      query.toLowerCase().includes('failure') && s.includes('failure')
    );
  };

  const getInsightIcon = (type: string) => {
    switch (type) {
      case 'performance': return <TrendingUp className="w-4 h-4 text-green-500" />;
      case 'prediction': return <Brain className="w-4 h-4 text-blue-500" />;
      case 'anomaly': return <AlertTriangle className="w-4 h-4 text-red-500" />;
      case 'optimization': return <Bot className="w-4 h-4 text-purple-500" />;
      default: return <Brain className="w-4 h-4 text-gray-500" />;
    }
  };

  const getSeverityColor = (severity: string) => {
    switch (severity) {
      case 'high': return 'text-red-600 bg-red-50';
      case 'medium': return 'text-yellow-600 bg-yellow-50';
      case 'low': return 'text-green-600 bg-green-50';
      default: return 'text-gray-600 bg-gray-50';
    }
  };

  return (
    <div className="flex h-full bg-white">
      {/* AI Insights Panel */}
      <div className="w-80 border-r border-gray-200 p-4">
        <div className="mb-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">AI Insights</h3>
          
          <div className="space-y-3">
            {insights.map((insight, index) => (
              <div key={index} className="p-3 border rounded-lg">
                <div className="flex items-center justify-between mb-2">
                  <div className="flex items-center space-x-2">
                    {getInsightIcon(insight.type)}
                    <span className="font-medium text-gray-900">{insight.title}</span>
                  </div>
                  {insight.severity && (
                    <span className={`px-2 py-1 rounded text-xs font-medium ${getSeverityColor(insight.severity)}`}>
                      {insight.severity.toUpperCase()}
                    </span>
                  )}
                </div>
                <p className="text-sm text-gray-600 mb-2">{insight.description}</p>
                <div className="flex items-center justify-between">
                  <span className="text-2xl font-bold text-gray-900">{insight.value}</span>
                  {insight.trend && (
                    <div className="flex items-center space-x-1">
                      {insight.trend === 'up' && <TrendingUp className="w-4 h-4 text-green-500" />}
                      {insight.trend === 'down' && <TrendingUp className="w-4 h-4 text-red-500 rotate-180" />}
                      <span className="text-sm text-gray-500">
                        {insight.trend === 'stable' ? 'Stable' : 
                         insight.trend === 'up' ? 'Improving' : 'Declining'}
                      </span>
                    </div>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Quick Actions */}
        <div className="mb-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-3">Quick Actions</h3>
          <div className="grid grid-cols-2 gap-2">
            <button className="px-3 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 text-sm font-medium">
              Optimize Schedule
            </button>
            <button className="px-3 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 text-sm font-medium">
              Analyze Performance
            </button>
            <button className="px-3 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 text-sm font-medium">
              Predict Failures
            </button>
            <button className="px-3 py-2 bg-orange-600 text-white rounded-lg hover:bg-orange-700 text-sm font-medium">
              System Insights
            </button>
          </div>
        </div>
      </div>

      {/* AI Chat Interface */}
      <div className="flex-1 flex flex-col">
        <div className="flex-1 border rounded-lg">
          <div className="p-4 border-b bg-gray-50">
            <div className="flex items-center space-x-2">
              <Bot className="w-5 h-5 text-blue-600" />
              <h3 className="text-lg font-semibold text-gray-900">FlowOps AI Assistant</h3>
            </div>
          </div>

          {/* Messages */}
          <div className="flex-1 p-4 overflow-y-auto" style={{ minHeight: '400px' }}>
            {messages.map((message) => (
              <div
                key={message.id}
                className={`mb-4 ${message.type === 'user' ? 'text-right' : 'text-left'}`}
              >
                <div className={`inline-block max-w-xs px-4 py-2 rounded-lg ${
                  message.type === 'user' 
                    ? 'bg-blue-600 text-white' 
                    : 'bg-gray-100 text-gray-900'
                }`}>
                  <p className="text-sm">{message.content}</p>
                  {message.suggestions && (
                    <div className="mt-2 pt-2 border-t border-gray-200">
                      <p className="text-xs font-medium text-gray-600 mb-1">AI Suggestions:</p>
                      <ul className="text-xs text-gray-500">
                        {message.suggestions.map((suggestion, idx) => (
                          <li key={idx}>• {suggestion}</li>
                        ))}
                      </ul>
                    </div>
                  )}
                </div>
                <p className="text-xs text-gray-500 mt-1">
                  {new Date(message.timestamp).toLocaleTimeString()}
                </p>
              </div>
            ))}

            {isTyping && (
              <div className="text-left mb-4">
                <div className="inline-block px-4 py-2 bg-gray-100 text-gray-900 rounded-lg">
                  <div className="flex items-center space-x-2">
                    <div className="flex space-x-1">
                      <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce"></div>
                      <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '0.1s' }}></div>
                      <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '0.2s' }}></div>
                    </div>
                    <span className="text-sm">AI is thinking...</span>
                  </div>
                </div>
              </div>
            )}
          </div>

          {/* Input */}
          <div className="p-4 border-t bg-gray-50">
            <div className="flex space-x-2">
              <input
                type="text"
                value={input}
                onChange={(e) => setInput(e.target.value)}
                onKeyPress={(e) => e.key === 'Enter' && handleSend()}
                placeholder="Ask AI about job optimization, performance, or scheduling..."
                className="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
              <button
                onClick={handleSend}
                disabled={!input.trim()}
                className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <Send className="w-4 h-4" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
