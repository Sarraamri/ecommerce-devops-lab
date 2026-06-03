# Node.js e-commerce app, run under PM2 (as required by the lab).
FROM node:20-alpine

WORKDIR /usr/src/app

# Install PM2 process manager globally
RUN npm install -g pm2

# Install app dependencies first (better layer caching)
COPY package.json ./
RUN npm install --omit=dev

# Copy application source
COPY . .

EXPOSE 3000

# Run the app under PM2 in the foreground (pm2-runtime keeps the container alive)
CMD ["pm2-runtime", "start", "server.js", "--name", "ecommerce"]
