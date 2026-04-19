// Basic Express.js server for the automotive blockchain supply chain MVP.
// Loads environment variables and connects route handlers.

const express = require('express');
const dotenv = require('dotenv');

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// Route modules for vehicle, shipment, dealer, and ownership operations
const vehicleRoutes = require('./routes/vehicle');
const shipmentRoutes = require('./routes/shipment');
const dealerRoutes = require('./routes/dealer');
const ownershipRoutes = require('./routes/ownership');

app.use('/vehicle', vehicleRoutes);
app.use('/shipment', shipmentRoutes);
app.use('/dealer', dealerRoutes);
app.use('/ownership', ownershipRoutes);

app.get('/', (req, res) => {
  res.send('Automotive Blockchain Supply Chain MVP API');
});

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
