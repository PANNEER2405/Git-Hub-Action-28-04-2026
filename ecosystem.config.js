module.exports = {
  apps: [
    {
      name:         'my-node-app',
      script:       'src/app.js',
      instances:    1,               // increase for load balancing
      autorestart:  true,
      watch:        false,           // never watch in production
      max_memory_restart: '200M',
      env: {
        NODE_ENV:     'production',
        PORT:         3000,
      }
    }
  ]
};
