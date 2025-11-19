# Use an official Node.js 18 image. 'alpine' is a lightweight version.
FROM node:18-alpine

# Create and set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install the app's dependencies
RUN npm install

# Copy the rest of the app's code (index.js)
COPY . .

# Tell Docker the app runs on port 8080
EXPOSE 8080

# The command to run when the container starts
CMD ["node", "index.js"]