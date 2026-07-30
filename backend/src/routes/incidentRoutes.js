const router = require('express').Router();
const incidentController = require('../controllers/incidentController');
const authMiddleware = require('../middleware/authMiddleware');

router.use(authMiddleware);

router.get('/', incidentController.getIncidents);
router.get('/:id', incidentController.getIncidentDetail);
router.post('/:id/media', incidentController.upload.single('file'), incidentController.uploadMedia);

module.exports = router;
