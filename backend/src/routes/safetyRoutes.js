const router = require('express').Router();
const safetyController = require('../controllers/safetyController');
const authMiddleware = require('../middleware/authMiddleware');

router.use(authMiddleware);

router.get('/zones', safetyController.getNearbyZones);
router.get('/route', safetyController.getSafeRoute);
router.post('/report', safetyController.reportIncident);

module.exports = router;
