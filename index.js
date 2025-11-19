const express = require('express');
const app = express();
const PORT = 8080; // Using 8080, a common port for apps

app.get('/', (req, res) => {
  console.log('Request received!');
  res.json({
    message: 'Automate all the things!',
    timestamp: Math.floor(Date.now() / 1000) // Timestamp in seconds
  });
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});