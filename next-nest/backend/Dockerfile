FROM node:20-slim

# Install openssl and netcat-openbsd for Prisma engine compatibility
RUN apt-get update && apt-get install -y openssl netcat-openbsd && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app

# Copy dependency specifications and Prisma schema
COPY package*.json ./
COPY prisma ./prisma/

# Install dependencies and generate Prisma client artifacts
RUN npm install
RUN npx prisma generate

# Copy source files
COPY . .

# Compile application
RUN npm run build

EXPOSE 3000

# Start NestJS development server with watch mode
CMD ["npm", "run", "start:dev"]
