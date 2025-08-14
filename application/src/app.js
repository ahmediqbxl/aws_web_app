const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const morgan = require('morgan');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
const { body, validationResult } = require('express-validator');

const app = express();
const PORT = process.env.PORT || 3000;
const NODE_ENV = process.env.NODE_ENV || 'development';

// Security middleware
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"],
    },
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true
  }
}));

// CORS configuration
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS ? process.env.ALLOWED_ORIGINS.split(',') : '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later.',
  standardHeaders: true,
  legacyHeaders: false,
});
app.use(limiter);

// Compression middleware
app.use(compression());

// Logging middleware
if (NODE_ENV === 'production') {
  app.use(morgan('combined'));
} else {
  app.use(morgan('dev'));
}

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Health check endpoint
app.get('/health', (req, res) => {
  const healthCheck = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: NODE_ENV,
    version: process.env.npm_package_version || '1.0.0',
    memory: process.memoryUsage(),
    cpu: process.cpuUsage()
  };
  
  res.status(200).json(healthCheck);
});

// Readiness check endpoint
app.get('/ready', (req, res) => {
  // Add any readiness checks here (database connections, external services, etc.)
  const readinessCheck = {
    status: 'ready',
    timestamp: new Date().toISOString(),
    checks: {
      database: 'connected',
      redis: 'connected',
      external_api: 'available'
    }
  };
  
  res.status(200).json(readinessCheck);
});

// Metrics endpoint for monitoring
app.get('/metrics', (req, res) => {
  const metrics = {
    timestamp: new Date().toISOString(),
    process: {
      uptime: process.uptime(),
      memory: process.memoryUsage(),
      cpu: process.cpuUsage(),
      pid: process.pid,
      version: process.version,
      platform: process.platform
    },
    system: {
      node_env: NODE_ENV,
      port: PORT,
      hostname: require('os').hostname()
    }
  };
  
  res.status(200).json(metrics);
});

// Main application routes
app.get('/', (req, res) => {
  res.json({
    message: 'Welcome to DevOps Web Application!',
    version: process.env.npm_package_version || '1.0.0',
    environment: NODE_ENV,
    timestamp: new Date().toISOString(),
    endpoints: {
      health: '/health',
      ready: '/ready',
      metrics: '/metrics',
      api: '/api'
    }
  });
});

// API routes
app.get('/api/status', (req, res) => {
  res.json({
    status: 'operational',
    service: 'devops-webapp',
    timestamp: new Date().toISOString()
  });
});

// Example POST endpoint with validation
app.post('/api/data', 
  [
    body('name').isLength({ min: 3 }).trim().escape(),
    body('email').isEmail().normalizeEmail(),
    body('message').isLength({ min: 10, max: 1000 }).trim().escape()
  ],
  (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ 
        status: 'error',
        errors: errors.array() 
      });
    }

    const { name, email, message } = req.body;
    
    // Process the data (in a real app, you'd save to database)
    const processedData = {
      id: Date.now(),
      name,
      email,
      message,
      timestamp: new Date().toISOString(),
      processed: true
    };

    res.status(201).json({
      status: 'success',
      message: 'Data processed successfully',
      data: processedData
    });
  }
);

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    status: 'error',
    message: 'Endpoint not found',
    path: req.originalUrl,
    timestamp: new Date().toISOString()
  });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('Error:', err);
  
  const errorResponse = {
    status: 'error',
    message: NODE_ENV === 'production' ? 'Internal server error' : err.message,
    timestamp: new Date().toISOString(),
    path: req.originalUrl
  };

  if (NODE_ENV === 'development') {
    errorResponse.stack = err.stack;
  }

  res.status(err.status || 500).json(errorResponse);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  server.close(() => {
    console.log('Process terminated');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('SIGINT received, shutting down gracefully');
  server.close(() => {
    console.log('Process terminated');
    process.exit(0);
  });
});

// Start server
const server = app.listen(PORT, () => {
  console.log(`🚀 DevOps Web Application running on port ${PORT}`);
  console.log(`🌍 Environment: ${NODE_ENV}`);
  console.log(`📊 Health check: http://localhost:${PORT}/health`);
  console.log(`✅ Readiness check: http://localhost:${PORT}/ready`);
  console.log(`📈 Metrics: http://localhost:${PORT}/metrics`);
});

module.exports = app; 