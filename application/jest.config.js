module.exports = {
  // Test environment
  testEnvironment: 'node',
  
  // Test file patterns
  testMatch: [
    '**/test/**/*.test.js',
    '**/__tests__/**/*.js'
  ],
  
  // Coverage configuration
  collectCoverage: true,
  coverageDirectory: 'coverage',
  coverageReporters: ['text', 'lcov', 'html'],
  collectCoverageFrom: [
    'src/**/*.js',
    '!src/**/*.test.js',
    '!src/**/test/**/*.js'
  ],
  
  // Coverage thresholds
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80
    }
  },
  
  // Setup files
  setupFilesAfterEnv: [],
  
  // Test timeout
  testTimeout: 10000,
  
  // Verbose output
  verbose: true,
  
  // Clear mocks between tests
  clearMocks: true,
  
  // Restore mocks between tests
  restoreMocks: true,
  
  // Module file extensions
  moduleFileExtensions: ['js', 'json'],
  
  // Transform configuration
  transform: {},
  
  // Ignore patterns
  testPathIgnorePatterns: [
    '/node_modules/',
    '/dist/',
    '/build/'
  ],
  
  // Watch plugins
  watchPlugins: [
    'jest-watch-typeahead/filename',
    'jest-watch-typeahead/testname'
  ],
  
  // Global setup and teardown
  globalSetup: undefined,
  globalTeardown: undefined,
  
  // Test results processor
  testResultsProcessor: undefined,
  
  // Reporters
  reporters: [
    'default',
    ['jest-junit', {
      outputDirectory: 'coverage',
      outputName: 'junit.xml',
      classNameTemplate: '{classname}-{title}',
      titleTemplate: '{classname}-{title}',
      ancestorSeparator: ' › ',
      usePathForSuiteName: true
    }]
  ],
  
  // Environment variables for tests
  setupFiles: [],
  
  // Test environment options
  testEnvironmentOptions: {},
  
  // Unmocked module path patterns
  unmockedModulePathPatterns: [],
  
  // Update snapshots
  updateSnapshot: false,
  
  // Use real timers
  timers: 'real',
  
  // Transform ignore patterns
  transformIgnorePatterns: [
    '/node_modules/'
  ],
  
  // Module name mapper
  moduleNameMapper: {},
  
  // Module path mapping
  modulePaths: [],
  
  // Preprocessor ignore patterns
  preprocessorIgnorePatterns: [],
  
  // Root directory
  rootDir: '.',
  
  // Roots
  roots: ['<rootDir>'],
  
  // Runtime
  runtime: undefined,
  
  // Script preprocessor
  scriptPreprocessor: undefined,
  
  // Snapshot serializers
  snapshotSerializers: [],
  
  // Test location
  testLocationInResults: false,
  
  // Test name pattern
  testNamePattern: '',
  
  // Test path pattern
  testPathPattern: '',
  
  // Test regex
  testRegex: '',
  
  // Test URL
  testURL: 'http://localhost',
  
  // Use coverage
  useCoverage: true,
  
  // Watch
  watch: false,
  
  // Watch all
  watchAll: false,
  
  // Watchman
  watchman: true
}; 