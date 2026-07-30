const router = require('express').Router();
const sosController = require('../controllers/sosController');
const authMiddleware = require('../middleware/authMiddleware');

router.use(authMiddleware);

router.post('/trigger', sosController.triggerSos);
router.put('/:id/resolve', sosController.resolveSos);
router.get('/active', sosController.getActiveSos);

module.exports = router;
