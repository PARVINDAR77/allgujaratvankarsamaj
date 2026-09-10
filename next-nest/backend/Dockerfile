FROM node:20-alpine3.20

# Install openssl and libc6-compat for Prisma engine compatibility on Alpine
RUN apk add --no-cache openssl libc6-compat netcat-openbsd

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
