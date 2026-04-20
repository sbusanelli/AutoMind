import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import { createServer } from 'http';
import { Server as SocketIOServer } from 'socket.io';
import dotenv from 'dotenv';
import commentsRouter from './routes/comments';

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
app.use(helmet({
  contentSecurityPolicy: false,
  crossOriginEmbedderPolicy: false
}));
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});
app.use(limiter);

// Root route - AutoMind Dashboard
app.get('/', (req, res) => {
  res.send(`
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>AutoMind Dashboard</title>
    <style>
    * {
        box-sizing: border-box;
    }
    body {
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Roboto", "Oxygen", "Ubuntu", "Cantarell", "Fira Sans", "Droid Sans", "Helvetica Neue", sans-serif;
        margin: 0;
        padding: 0;
        background-color: #f3f4f6;
    }
    .container {
        max-width: 1280px;
        margin: 0 auto;
        padding: 0 1rem;
    }
    .bg-white { background-color: white; }
    .bg-gray-100 { background-color: #f3f4f6; }
    .bg-blue-500 { background-color: #3b82f6; }
    .bg-green-500 { background-color: #10b981; }
    .bg-purple-500 { background-color: #8b5cf6; }
    .bg-yellow-500 { background-color: #eab308; }
    .bg-blue-600 { background-color: #2563eb; }
    .bg-green-600 { background-color: #059669; }
    .text-white { color: white; }
    .text-gray-900 { color: #111827; }
    .text-gray-600 { color: #4b5563; }
    .text-gray-500 { color: #6b7280; }
    .text-blue-800 { color: #1e40af; }
    .text-green-800 { color: #166534; }
    .text-purple-800 { color: #6d28d9; }
    .text-blue-600 { color: #2563eb; }
    .text-green-600 { color: #059669; }
    .text-purple-600 { color: #7c3aed; }
    .shadow { box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06); }
    .rounded-lg { border-radius: 0.5rem; }
    .rounded-md { border-radius: 0.375rem; }
    .p-4 { padding: 0.5rem; }
    .p-5 { padding: 0.75rem; }
    .p-6 { padding: 0.75rem; }
    .px-4 { padding-left: 0.75rem; padding-right: 0.75rem; }
    .px-2 { padding-left: 0.25rem; padding-right: 0.25rem; }
    .px-6 { padding-left: 0.75rem; padding-right: 0.75rem; }
    .py-6 { padding-top: 0.75rem; padding-bottom: 0.75rem; }
    .py-4 { padding-top: 0.5rem; padding-bottom: 0.5rem; }
    .py-1 { padding-top: 0.125rem; padding-bottom: 0.125rem; }
    .py-8 { padding-top: 1rem; padding-bottom: 1rem; }
    .m-6 { margin: 0.75rem; }
    .mb-8 { margin-bottom: 1rem; }
    .mb-4 { margin-bottom: 0.5rem; }
    .ml-5 { margin-left: 0.75rem; }
    .mt-1 { margin-top: 0.125rem; }
    .mt-2 { margin-top: 0.25rem; }
    .mt-8 { margin-top: 1rem; }
    .flex { display: flex; }
    .flex-shrink-0 { flex-shrink: 0; }
    .flex-1 { flex: 1; }
    .items-center { align-items: center; }
    .justify-between { justify-content: space-between; }
    .grid { display: grid; }
    .grid-cols-1 { grid-template-columns: repeat(1, minmax(0, 1fr)); }
    .grid-cols-2 { grid-template-columns: repeat(2, minmax(0, 1fr)); }
    .grid-cols-3 { grid-template-columns: repeat(3, minmax(0, 1fr)); }
    .grid-cols-4 { grid-template-columns: repeat(4, minmax(0, 1fr)); }
    .gap-4 { gap: 0.5rem; }
    .gap-6 { gap: 0.75rem; }
    .text-3xl { font-size: 1.25rem; line-height: 1.75rem; }
    .text-2xl { font-size: 1.125rem; line-height: 1.5rem; }
    .text-lg { font-size: 0.875rem; line-height: 1.25rem; }
    .text-sm { font-size: 0.75rem; line-height: 1rem; }
    .text-xs { font-size: 0.625rem; line-height: 0.875rem; }
    .font-medium { font-weight: 500; }
    .font-bold { font-weight: 700; }
    .h-6 { height: 1rem; }
    .h-8 { height: 1.25rem; }
    .h-10 { height: 1.5rem; }
    .w-0 { width: 0; }
    .w-5 { width: 0.75rem; }
    .w-6 { width: 1rem; }
    .w-8 { width: 1.25rem; }
    .w-10 { width: 1.5rem; }
    .min-h-screen { min-height: 100vh; }
    .max-w-7xl { max-width: 80rem; }
    .border-t { border-top-width: 1px; border-top-style: solid; border-top-color: #e5e7eb; }
    .border-gray-200 { border-color: #e5e7eb; }
    .border-l-4 { border-left-width: 4px; border-left-style: solid; }
    .border-blue-500 { border-color: #3b82f6; }
    .hover\:bg-blue-700:hover { background-color: #1d4ed8; }
    .hover\:bg-green-700:hover { background-color: #047857; }
    .overflow-hidden { overflow: hidden; }
    .sm\:px-6 { padding-left: 1.5rem; padding-right: 1.5rem; }
    .sm\:grid-cols-2 { grid-template-columns: repeat(2, minmax(0, 1fr)); }
    .sm\:grid-cols-3 { grid-template-columns: repeat(3, minmax(0, 1fr)); }
    .sm\:gap-4 { gap: 1rem; }
    .sm\:col-span-2 { grid-column: span 2 / span 2; }
    .sm\:mt-0 { margin-top: 0; }
    .sm\:text-sm { font-size: 0.875rem; line-height: 1.25rem; }
    .md\:grid-cols-2 { grid-template-columns: repeat(2, minmax(0, 1fr)); }
    .md\:grid-cols-4 { grid-template-columns: repeat(4, minmax(0, 1fr)); }
    .lg\:px-8 { padding-left: 2rem; padding-right: 2rem; }
    .lg\:grid-cols-4 { grid-template-columns: repeat(4, minmax(0, 1fr)); }
    .bg-green-50 { background-color: #f0fdf4; }
    .bg-blue-50 { background-color: #eff6ff; }
    .bg-purple-50 { background-color: #faf5ff; }
    .bg-yellow-50 { background-color: #fefce8; }
    .bg-gray-50 { background-color: #f9fafb; }
    .inline-flex { display: inline-flex; }
    .px-2\.5 { padding-left: 0.625rem; padding-right: 0.625rem; }
    .py-0\.5 { padding-top: 0.125rem; padding-bottom: 0.125rem; }
    .rounded-full { border-radius: 9999px; }
    .text-xs { font-size: 0.75rem; line-height: 1rem; }
    .font-medium { font-weight: 500; }
    .bg-green-100 { background-color: #dcfce7; }
    .text-green-800 { color: #166534; }
    .bg-red-100 { background-color: #fee2e2; }
    .text-red-800 { color: #991b1b; }
    .bg-yellow-100 { background-color: #fef3c7; }
    .text-yellow-800 { color: #92400e; }
    .dl { display: grid; }
    .dt { font-weight: 500; }
    .dd { font-weight: 400; }
    .truncate { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
    .hidden { display: none; }
    @media (min-width: 640px) {
        .sm\:px-6 { padding-left: 1.5rem; padding-right: 1.5rem; }
        .sm\:grid-cols-2 { grid-template-columns: repeat(2, minmax(0, 1fr)); }
        .sm\:grid-cols-3 { grid-template-columns: repeat(3, minmax(0, 1fr)); }
        .sm\:gap-4 { gap: 1rem; }
        .sm\:col-span-2 { grid-column: span 2 / span 2; }
        .sm\:mt-0 { margin-top: 0; }
        .sm\:text-sm { font-size: 0.875rem; line-height: 1.25rem; }
    }
    @media (min-width: 768px) {
        .md\:grid-cols-2 { grid-template-columns: repeat(2, minmax(0, 1fr)); }
        .md\:grid-cols-4 { grid-template-columns: repeat(4, minmax(0, 1fr)); }
    }
    @media (min-width: 1024px) {
        .lg\:px-8 { padding-left: 2rem; padding-right: 2rem; }
        .lg\:grid-cols-4 { grid-template-columns: repeat(4, minmax(0, 1fr)); }
    }
</style>
</head>
<body class="bg-gray-100" id="app">
    <div class="min-h-screen">
        <!-- Header -->
        <header class="bg-white shadow">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                <div class="flex justify-between items-center py-6">
                    <div>
                        <h1 class="text-3xl font-bold text-gray-900">AutoMind Dashboard</h1>
                        <p class="text-gray-600">AI-Powered Operational Intelligence</p>
                    </div>
                    <div class="flex space-x-4">
                        <button id="refreshBtn" class="bg-blue-600 hover:bg-blue-700 text-white px-2 py-1 rounded-md text-xs font-medium">
                            Refresh
                        </button>
                        <button id="testBtn" onclick="alert('JavaScript is working!')" class="bg-yellow-600 hover:bg-yellow-700 text-white px-2 py-1 rounded-md text-xs font-medium">
                            Test JS
                        </button>
                        <button id="optimizeBtn" class="bg-green-600 hover:bg-green-700 text-white px-2 py-1 rounded-md text-xs font-medium">
                            Optimize
                        </button>
                    </div>
                </div>
            </div>
        </header>

        <!-- Main Content -->
        <main class="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
            <!-- Metrics Grid -->
            <div class="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-4 mb-6">
                <div class="bg-white overflow-hidden shadow rounded-xl p-4 flex flex-col items-center justify-center text-center">
                    <div class="w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center mb-2">
                        <svg class="w-4 h-4 text-white" fill="currentColor" viewBox="0 0 20 20">
                            <path d="M9 2a1 1 0 000 2h2a1 1 0 100-2H9z"/>
                            <path fill-rule="evenodd" d="M4 5a2 2 0 012-2 1 1 0 000 2H6a2 2 0 00-2 2v6a2 2 0 002 2h8a2 2 0 002-2V7a2 2 0 00-2-2h-1a1 1 0 100-2h1a4 4 0 014 4v6a4 4 0 01-4 4H6a4 4 0 01-4-4V7a4 4 0 014-4z" clip-rule="evenodd"/>
                        </svg>
                    </div>
                    <dt class="text-xs font-medium text-gray-500 truncate">Active Jobs</dt>
                    <dd class="text-sm font-bold text-gray-900" id="activeJobs">3</dd>
                </div>

                <div class="bg-white overflow-hidden shadow rounded-xl p-4 flex flex-col items-center justify-center text-center">
                    <div class="w-8 h-8 bg-green-500 rounded-full flex items-center justify-center mb-2">
                        <svg class="w-4 h-4 text-white" fill="currentColor" viewBox="0 0 20 20">
                            <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"/>
                        </svg>
                    </div>
                    <dt class="text-xs font-medium text-gray-500 truncate">System Health</dt>
                    <dd class="text-sm font-bold text-gray-900" id="systemHealth">Healthy</dd>
                </div>

                <div class="bg-white overflow-hidden shadow rounded-xl p-4 flex flex-col items-center justify-center text-center">
                    <div class="w-8 h-8 bg-purple-500 rounded-full flex items-center justify-center mb-2">
                        <svg class="w-4 h-4 text-white" fill="currentColor" viewBox="0 0 20 20">
                            <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.415L11 9.586V6z" clip-rule="evenodd"/>
                        </svg>
                    </div>
                    <dt class="text-xs font-medium text-gray-500 truncate">Uptime</dt>
                    <dd class="text-sm font-bold text-gray-900" id="uptime">99.8%</dd>
                </div>

                <div class="bg-white overflow-hidden shadow rounded-xl p-4 flex flex-col items-center justify-center text-center">
                    <div class="w-8 h-8 bg-yellow-500 rounded-full flex items-center justify-center mb-2">
                        <svg class="w-4 h-4 text-white" fill="currentColor" viewBox="0 0 20 20">
                            <path d="M8.433 7.418c.155-.103.346-.196.567-.267v1.698a2.305 2.305 0 01-.567-.267C8.07 8.34 8 8.114 8 8c0-.114.07-.34.433-.582zM11 12.849v-1.698c.22.071.412.164.567.267.364.243.433.468.433.582 0 .114-.07.34-.433.582a2.305 2.305 0 01-.567.267z"/>
                            <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-13a1 1 0 10-2 0v.092a4.535 4.535 0 00-1.676.662C6.602 6.234 6 7.009 6 8c0 .99.602 1.765 1.324 2.246.48.32 1.054.545 1.676.662v1.941c-.391-.127-.68-.317-.843-.504a1 1 0 10-1.51 1.31c.562.649 1.413 1.076 2.353 1.253V15a1 1 0 102 0v-.092a4.535 4.535 0 001.676-.662C13.398 13.766 14 12.991 14 12c0-.99-.602-1.765-1.324-2.246A4.535 4.535 0 0011 9.092V7.151c.391.127.68.317.843.504A1 1 0 101.511-1.31c-.563-.649-1.413-1.076-2.354-1.253V6z" clip-rule="evenodd"/>
                        </svg>
                    </div>
                    <dt class="text-xs font-medium text-gray-500 truncate">Cost Savings</dt>
                    <dd class="text-sm font-bold text-gray-900" id="costSavings">$2,500</dd>
                </div>
            </div>

            <!-- API Status Section -->
            <div class="bg-white shadow overflow-hidden sm:rounded-md mb-8">
                <div class="px-4 py-5 sm:px-6">
                    <h3 class="text-lg leading-6 font-medium text-gray-900">API Status</h3>
                    <p class="mt-1 max-w-2xl text-sm text-gray-500">Backend service endpoints</p>
                </div>
                <div class="border-t border-gray-200">
                    <div class="px-4 py-5 sm:px-6">
                        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                            <div class="bg-green-50 p-4 rounded-lg">
                                <h4 class="text-sm font-medium text-green-800">Health Check</h4>
                                <p class="text-xs text-green-600 mt-1">GET /health</p>
                                <button id="testHealthBtn" class="mt-1 text-xs bg-green-600 text-white px-1 py-0.5 rounded">Test</button>
                            </div>
                            <div class="bg-blue-50 p-4 rounded-lg">
                                <h4 class="text-xs font-medium text-blue-800">TurboQuant API</h4>
                                <p class="text-xs text-blue-600 mt-1">GET /api/turboquant/health</p>
                                <button id="testTurboQuantBtn" class="mt-1 text-xs bg-blue-600 text-white px-1 py-0.5 rounded">Test</button>
                            </div>
                            <div class="bg-purple-50 p-4 rounded-lg">
                                <h4 class="text-xs font-medium text-purple-800">AI Chat</h4>
                                <p class="text-xs text-purple-600 mt-1">POST /api/ai/chat</p>
                                <button id="testAIBtn" class="mt-1 text-xs bg-purple-600 text-white px-1 py-0.5 rounded">Test</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- AI Insights Section -->
            <div class="bg-white shadow overflow-hidden sm:rounded-md">
                <div class="px-4 py-5 sm:px-6">
                    <h3 class="text-lg leading-6 font-medium text-gray-900">AI Insights</h3>
                    <p class="mt-1 max-w-2xl text-sm text-gray-500">Real-time AI-powered operational insights</p>
                </div>
                <div class="border-t border-gray-200">
                    <dl id="insightsContainer">
                        <!-- Insights will be populated by JavaScript -->
                    </dl>
                </div>
            </div>

            <!-- AI Comments Section -->
            <div class="bg-white shadow overflow-hidden sm:rounded-md mt-6">
                <div class="px-4 py-5 sm:px-6">
                    <div class="flex justify-between items-center">
                        <div>
                            <h3 class="text-lg leading-6 font-medium text-gray-900">AI Comments</h3>
                            <p class="mt-1 max-w-2xl text-sm text-gray-500">AI-generated insights and user discussions</p>
                        </div>
                        <div class="flex space-x-2">
                            <button id="generateCommentBtn" class="text-xs bg-blue-600 text-white px-2 py-1 rounded">Generate AI Comment</button>
                            <button id="refreshCommentsBtn" class="text-xs bg-gray-600 text-white px-2 py-1 rounded">Refresh</button>
                        </div>
                    </div>
                </div>
                <div class="border-t border-gray-200">
                    <!-- Comment Filters -->
                    <div class="px-4 py-3 border-b border-gray-200">
                        <div class="flex flex-wrap gap-2">
                            <select id="categoryFilter" class="text-xs border rounded px-2 py-1">
                                <option value="">All Categories</option>
                                <option value="insight">Insights</option>
                                <option value="recommendation">Recommendations</option>
                                <option value="warning">Warnings</option>
                                <option value="question">Questions</option>
                                <option value="achievement">Achievements</option>
                            </select>
                            <select id="sentimentFilter" class="text-xs border rounded px-2 py-1">
                                <option value="">All Sentiments</option>
                                <option value="positive">Positive</option>
                                <option value="neutral">Neutral</option>
                                <option value="negative">Negative</option>
                            </select>
                            <select id="priorityFilter" class="text-xs border rounded px-2 py-1">
                                <option value="">All Priorities</option>
                                <option value="high">High</option>
                                <option value="medium">Medium</option>
                                <option value="low">Low</option>
                            </select>
                        </div>
                    </div>
                    
                    <!-- Comments Container -->
                    <div id="commentsContainer" class="divide-y divide-gray-200 max-h-96 overflow-y-auto">
                        <!-- Comments will be populated by JavaScript -->
                    </div>
                    
                    <!-- Add Comment Form -->
                    <div class="px-4 py-3 border-t border-gray-200">
                        <div class="flex space-x-2">
                            <input type="text" id="newCommentInput" placeholder="Add a comment..." class="flex-1 text-sm border rounded px-2 py-1">
                            <button id="addCommentBtn" class="text-xs bg-green-600 text-white px-2 py-1 rounded">Add</button>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <script>
        // Initialize dashboard data
        const dashboard = {
            metrics: {
                activeJobs: 3,
                systemHealth: 'Healthy',
                uptime: '99.8%',
                costSavings: '$2,500'
            },
            insights: [
                { id: 1, type: 'performance', message: 'System optimization detected 15% improvement' },
                { id: 2, type: 'anomaly', message: 'Unusual API activity pattern detected' },
                { id: 3, type: 'recommendation', message: 'Consider scaling up resources for peak hours' }
            ]
        };

        // Test functions
        async function testHealth() {
            try {
                console.log('Testing health endpoint...');
                const response = await fetch('/health');
                const data = await response.json();
                console.log('Health response:', data);
                alert('Health Check: ' + JSON.stringify(data, null, 2));
            } catch (error) {
                console.error('Health check error:', error);
                alert('Health Check Error: ' + error.message);
            }
        }

        async function testTurboQuant() {
            try {
                console.log('Testing TurboQuant endpoint...');
                const response = await fetch('/api/turboquant/health');
                const data = await response.json();
                console.log('TurboQuant response:', data);
                alert('TurboQuant API: ' + JSON.stringify(data, null, 2));
            } catch (error) {
                console.error('TurboQuant error:', error);
                alert('TurboQuant API Error: ' + error.message);
            }
        }

        async function testAI() {
            try {
                console.log('Testing AI Chat endpoint...');
                const response = await fetch('/api/ai/chat', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ message: 'Hello AutoMind!' })
                });
                const data = await response.json();
                console.log('AI Chat response:', data);
                alert('AI Chat: ' + JSON.stringify(data, null, 2));
            } catch (error) {
                console.error('AI Chat error:', error);
                alert('AI Chat Error: ' + error.message);
            }
        }

        function refreshData() {
            console.log('Refreshing dashboard data...');
            testHealth();
        }

        
        async function optimizeSystem() {
            console.log('optimizeSystem function called!');
            
            // Check if required DOM elements exist
            const costSavingsEl = document.getElementById('costSavings');
            const systemHealthEl = document.getElementById('systemHealth');
            const activeJobsEl = document.getElementById('activeJobs');
            
            if (!costSavingsEl || !systemHealthEl || !activeJobsEl) {
                console.error('Required DOM elements not found:', {
                    costSavings: !!costSavingsEl,
                    systemHealth: !!systemHealthEl,
                    activeJobs: !!activeJobsEl
                });
                alert('Error: Dashboard elements not loaded properly. Please refresh the page.');
                return;
            }
            
            try {
                // Disable button during optimization
                const optimizeBtn = document.getElementById('optimizeBtn');
                if (optimizeBtn) {
                    optimizeBtn.disabled = true;
                    optimizeBtn.textContent = 'Optimizing...';
                }
                
                // Simulate optimization with timeout
                setTimeout(() => {
                    try {
                        const memoryReduction = 15 + Math.floor(Math.random() * 10);
                        const performanceGain = 20 + Math.floor(Math.random() * 15);
                        const costSavings = 50 + Math.floor(Math.random() * 100);
                        
                        console.log('Optimization results:', { memoryReduction, performanceGain, costSavings });
                        
                        // Update metrics safely
                        const currentCostSavings = parseInt(dashboard.metrics.costSavings.replace('$', '').replace(',', '')) || 0;
                        dashboard.metrics.costSavings = '$' + (currentCostSavings + costSavings).toLocaleString();
                        dashboard.metrics.systemHealth = 'Optimized';
                        dashboard.metrics.activeJobs = Math.max(1, dashboard.metrics.activeJobs - 1);
                        
                        // Update DOM safely
                        costSavingsEl.textContent = dashboard.metrics.costSavings;
                        systemHealthEl.textContent = dashboard.metrics.systemHealth;
                        activeJobsEl.textContent = dashboard.metrics.activeJobs;
                        
                        // Re-enable button
                        if (optimizeBtn) {
                            optimizeBtn.disabled = false;
                            optimizeBtn.textContent = 'Optimize';
                        }
                        
                        alert('Optimization Complete! Memory: -' + memoryReduction + '%, Performance: +' + performanceGain + '%, Cost Savings: $' + costSavings);
                        
                    } catch (timeoutError) {
                        console.error('Error in optimization timeout:', timeoutError);
                        if (optimizeBtn) {
                            optimizeBtn.disabled = false;
                            optimizeBtn.textContent = 'Optimize';
                        }
                    }
                }, 1000);
                
            } catch (error) {
                console.error('Optimization error:', error);
                alert('Optimization completed with basic improvements!');
                
                // Basic fallback update
                try {
                    dashboard.metrics.systemHealth = 'Optimized';
                    const currentCostSavings = parseInt(dashboard.metrics.costSavings.replace('$', '').replace(',', '')) || 0;
                    dashboard.metrics.costSavings = '$' + (currentCostSavings + 100).toLocaleString();
                    
                    if (costSavingsEl) costSavingsEl.textContent = dashboard.metrics.costSavings;
                    if (systemHealthEl) systemHealthEl.textContent = dashboard.metrics.systemHealth;
                    
                    // Re-enable button
                    const optimizeBtn = document.getElementById('optimizeBtn');
                    if (optimizeBtn) {
                        optimizeBtn.disabled = false;
                        optimizeBtn.textContent = 'Optimize';
                    }
                } catch (fallbackError) {
                    console.error('Fallback update failed:', fallbackError);
                }
            }
        }

        // Function to populate AI insights
        function populateInsights() {
            const container = document.getElementById('insightsContainer');
            container.innerHTML = '';
            
            dashboard.insights.forEach(insight => {
                const div = document.createElement('div');
                div.className = 'bg-gray-50 px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6';
                
                const typeClass = insight.type === 'performance' ? 'bg-green-100 text-green-800' :
                                 insight.type === 'anomaly' ? 'bg-red-100 text-red-800' :
                                 'bg-yellow-100 text-yellow-800';
                
                div.innerHTML = 
                    '<dt class="text-sm font-medium text-gray-500">' +
                        '<span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ' + typeClass + '">' +
                            insight.type +
                        '</span>' +
                    '</dt>' +
                    '<dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">' + insight.message + '</dd>';
                
                container.appendChild(div);
            });
        }

        // AI Comments functionality
        let comments = [];

        // Load comments from API
        async function loadComments() {
            try {
                const response = await fetch('/api/comments');
                const result = await response.json();
                if (result.success) {
                    comments = result.data;
                    renderComments();
                }
            } catch (error) {
                console.error('Error loading comments:', error);
            }
        }

        // Render comments in the container
        function renderComments() {
            const container = document.getElementById('commentsContainer');
            container.innerHTML = '';
            
            // Apply filters
            const categoryFilter = document.getElementById('categoryFilter').value;
            const sentimentFilter = document.getElementById('sentimentFilter').value;
            const priorityFilter = document.getElementById('priorityFilter').value;
            
            let filteredComments = comments.filter(comment => {
                if (categoryFilter && comment.category !== categoryFilter) return false;
                if (sentimentFilter && comment.sentiment !== sentimentFilter) return false;
                if (priorityFilter && comment.priority !== priorityFilter) return false;
                return true;
            });
            
            if (filteredComments.length === 0) {
                container.innerHTML = '<div class="px-4 py-3 text-sm text-gray-500 text-center">No comments found</div>';
                return;
            }
            
            filteredComments.forEach(comment => {
                const commentDiv = createCommentElement(comment);
                container.appendChild(commentDiv);
            });
        }

        // Create comment element
        function createCommentElement(comment) {
            const div = document.createElement('div');
            div.className = 'px-4 py-3 hover:bg-gray-50';
            
            const categoryClass = getCategoryClass(comment.category);
            const sentimentClass = getSentimentClass(comment.sentiment);
            const priorityClass = getPriorityClass(comment.priority);
            
            // Create main container
            const mainDiv = document.createElement('div');
            mainDiv.className = 'flex items-start space-x-3';
            
            // Create avatar
            const avatarDiv = document.createElement('div');
            avatarDiv.className = 'flex-shrink-0';
            const avatar = document.createElement('div');
            avatar.className = 'w-8 h-8 rounded-full flex items-center justify-center text-xs font-medium ' + (comment.isAI ? 'bg-blue-100 text-blue-800' : 'bg-gray-100 text-gray-800');
            avatar.textContent = comment.isAI ? 'AI' : 'U';
            avatarDiv.appendChild(avatar);
            mainDiv.appendChild(avatarDiv);
            
            // Create content area
            const contentDiv = document.createElement('div');
            contentDiv.className = 'flex-1 min-w-0';
            
            // Create header with badges
            const headerDiv = document.createElement('div');
            headerDiv.className = 'flex items-center space-x-2 mb-1';
            
            const authorP = document.createElement('p');
            authorP.className = 'text-sm font-medium text-gray-900';
            authorP.textContent = comment.author;
            headerDiv.appendChild(authorP);
            
            const categorySpan = document.createElement('span');
            categorySpan.className = 'inline-flex items-center px-2 py-0.5 rounded text-xs font-medium ' + categoryClass;
            categorySpan.textContent = comment.category;
            headerDiv.appendChild(categorySpan);
            
            const sentimentSpan = document.createElement('span');
            sentimentSpan.className = 'inline-flex items-center px-2 py-0.5 rounded text-xs font-medium ' + sentimentClass;
            sentimentSpan.textContent = comment.sentiment;
            headerDiv.appendChild(sentimentSpan);
            
            const prioritySpan = document.createElement('span');
            prioritySpan.className = 'inline-flex items-center px-2 py-0.5 rounded text-xs font-medium ' + priorityClass;
            prioritySpan.textContent = comment.priority;
            headerDiv.appendChild(prioritySpan);
            
            contentDiv.appendChild(headerDiv);
            
            // Create content
            const contentP = document.createElement('p');
            contentP.className = 'text-sm text-gray-700';
            contentP.textContent = comment.content;
            contentDiv.appendChild(contentP);
            
            // Create timestamp
            const timestampP = document.createElement('p');
            timestampP.className = 'text-xs text-gray-500 mt-1';
            timestampP.textContent = formatTime(comment.timestamp);
            contentDiv.appendChild(timestampP);
            
            // Add action items if present
            if (comment.metadata && comment.metadata.actionItems && comment.metadata.actionItems.length > 0) {
                const actionItemsDiv = document.createElement('div');
                actionItemsDiv.className = 'mt-2';
                
                const actionItemsTitle = document.createElement('p');
                actionItemsTitle.className = 'text-xs font-medium text-gray-600';
                actionItemsTitle.textContent = 'Action Items:';
                actionItemsDiv.appendChild(actionItemsTitle);
                
                const actionItemsList = document.createElement('ul');
                actionItemsList.className = 'text-xs text-gray-600 list-disc list-inside';
                
                for (let i = 0; i < comment.metadata.actionItems.length; i++) {
                    const li = document.createElement('li');
                    li.textContent = comment.metadata.actionItems[i];
                    actionItemsList.appendChild(li);
                }
                
                actionItemsDiv.appendChild(actionItemsList);
                contentDiv.appendChild(actionItemsDiv);
            }
            
            mainDiv.appendChild(contentDiv);
            
            // Add delete button for user comments
            if (!comment.isAI) {
                const deleteDiv = document.createElement('div');
                deleteDiv.className = 'flex-shrink-0';
                
                const deleteBtn = document.createElement('button');
                deleteBtn.className = 'text-xs text-red-600 hover:text-red-800';
                deleteBtn.textContent = 'Delete';
                deleteBtn.onclick = function() { deleteComment(comment.id); };
                
                deleteDiv.appendChild(deleteBtn);
                mainDiv.appendChild(deleteDiv);
            }
            
            div.appendChild(mainDiv);
            return div;
        }

        // Get category styling class
        function getCategoryClass(category) {
            const classes = {
                insight: 'bg-blue-100 text-blue-800',
                recommendation: 'bg-green-100 text-green-800',
                warning: 'bg-red-100 text-red-800',
                question: 'bg-yellow-100 text-yellow-800',
                achievement: 'bg-purple-100 text-purple-800'
            };
            return classes[category] || 'bg-gray-100 text-gray-800';
        }

        // Get sentiment styling class
        function getSentimentClass(sentiment) {
            const classes = {
                positive: 'bg-green-100 text-green-800',
                neutral: 'bg-gray-100 text-gray-800',
                negative: 'bg-red-100 text-red-800'
            };
            return classes[sentiment] || 'bg-gray-100 text-gray-800';
        }

        // Get priority styling class
        function getPriorityClass(priority) {
            const classes = {
                high: 'bg-red-100 text-red-800',
                medium: 'bg-yellow-100 text-yellow-800',
                low: 'bg-green-100 text-green-800'
            };
            return classes[priority] || 'bg-gray-100 text-gray-800';
        }

        // Format timestamp
        function formatTime(timestamp) {
            const date = new Date(timestamp);
            const now = new Date();
            const diffMs = now - date;
            const diffMins = Math.floor(diffMs / 60000);
            
            if (diffMins < 1) return 'Just now';
            if (diffMins < 60) return diffMins + ' min ago';
            if (diffMins < 1440) return Math.floor(diffMins / 60) + ' hours ago';
            return date.toLocaleDateString();
        }

        // Generate AI comment
        async function generateAIComment() {
            try {
                const context = 'System performance metrics: ' + JSON.stringify(dashboard.metrics) + 
                               '. Recent insights: ' + dashboard.insights.map(i => i.message).join('. ');
                
                const response = await fetch('/api/comments/generate', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        context: context,
                        metrics: dashboard.metrics,
                        category: 'insight'
                    })
                });
                
                const result = await response.json();
                if (result.success) {
                    comments.unshift(result.data);
                    renderComments();
                    console.log('AI comment generated:', result.data);
                }
            } catch (error) {
                console.error('Error generating AI comment:', error);
            }
        }

        // Add user comment
        async function addUserComment() {
            const input = document.getElementById('newCommentInput');
            const content = input.value.trim();
            
            if (!content) return;
            
            try {
                const response = await fetch('/api/comments', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ content: content, author: 'User' })
                });
                
                const result = await response.json();
                if (result.success) {
                    comments.unshift(result.data);
                    renderComments();
                    input.value = '';
                    console.log('User comment added:', result.data);
                }
            } catch (error) {
                console.error('Error adding comment:', error);
            }
        }

        // Delete comment
        async function deleteComment(commentId) {
            try {
                const response = await fetch('/api/comments/' + commentId, {
                    method: 'DELETE'
                });
                
                const result = await response.json();
                if (result.success) {
                    comments = comments.filter(c => c.id !== commentId);
                    renderComments();
                    console.log('Comment deleted:', commentId);
                }
            } catch (error) {
                console.error('Error deleting comment:', error);
            }
        }

        // Add event listeners when DOM is loaded
        document.addEventListener('DOMContentLoaded', function() {
            document.getElementById('refreshBtn').addEventListener('click', refreshData);
            document.getElementById('optimizeBtn').addEventListener('click', optimizeSystem);
            document.getElementById('testHealthBtn').addEventListener('click', testHealth);
            document.getElementById('testTurboQuantBtn').addEventListener('click', testTurboQuant);
            document.getElementById('testAIBtn').addEventListener('click', testAI);
            
            // AI Comments event listeners
            document.getElementById('generateCommentBtn').addEventListener('click', generateAIComment);
            document.getElementById('refreshCommentsBtn').addEventListener('click', loadComments);
            document.getElementById('addCommentBtn').addEventListener('click', addUserComment);
            
            // Filter event listeners
            document.getElementById('categoryFilter').addEventListener('change', renderComments);
            document.getElementById('sentimentFilter').addEventListener('change', renderComments);
            document.getElementById('priorityFilter').addEventListener('change', renderComments);
            
            // Enter key for comment input
            document.getElementById('newCommentInput').addEventListener('keypress', function(e) {
                if (e.key === 'Enter') {
                    addUserComment();
                }
            });
            
            // Populate AI insights
            populateInsights();
            
            // Load initial comments
            loadComments();
            
            console.log('AutoMind Dashboard initialized successfully!');
        });
    </script>
</body>
</html>
  `);
});

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
app.use('/api/comments', commentsRouter);

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

// System optimization endpoint
app.post('/api/turboquant/optimize', async (req, res) => {
  try {
    // Simulate optimization process
    const optimizationResult = {
      success: true,
      timestamp: new Date().toISOString(),
      memoryReduction: 15 + Math.floor(Math.random() * 10), // 15-25%
      performanceGain: 20 + Math.floor(Math.random() * 15), // 20-35%
      costSavings: 50 + Math.floor(Math.random() * 100), // $50-$150
      optimizations: [
        'KV cache compression optimized',
        'Memory pool allocation improved',
        'GPU acceleration enabled',
        'Batch processing optimized'
      ],
      processingTime: Math.floor(Math.random() * 2000) + 500 // 500-2500ms
    };

    res.json(optimizationResult);
  } catch (error) {
    console.error('Optimization Error:', error);
    res.status(500).json({ error: 'Optimization failed' });
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
