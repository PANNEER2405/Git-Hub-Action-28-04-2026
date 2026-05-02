module.exports = {
  apps: [
    {
      name: 'my-node-app',
      script: 'src/app.js',

      env: {
        NODE_ENV: 'development',
        PORT: 3000
      },

      env_production: {
        NODE_ENV: 'production',
        PORT: 3000,
        DB_HOST: '52.201.114.104',
        DB_USER: 'appuse',
        DB_PASSWORD: 'App@12345',
        DB_NAME: 'testdb'
      }
    }
  ]
};

