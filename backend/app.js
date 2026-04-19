// Express server setup for the Automotive Supply Chain MVP backend.
// Initializes JSON middleware and registers vehicle routes.

const express = require('express');
const dotenv = require('dotenv');

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

const vehicleRoutes = require('./routes/vehicleRoutes');
app.use('/vehicle', vehicleRoutes);

app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  const status = err.statusCode || 500;
  res.status(status).json({ success: false, error: err.message || 'Internal Server Error' });
});

app.listen(PORT, () => {
  console.log(`Automotive Supply Chain backend listening on port ${PORT}`);
});
