const router = require('express').Router();
const userController = require('../controllers/userController');
const authMiddleware = require('../middleware/authMiddleware');

router.use(authMiddleware);

router.get('/profile', userController.getProfile);
router.put('/profile', userController.updateProfile);
router.put('/contacts', userController.updateContacts);
router.put('/ai-settings', userController.updateAiSettings);

module.exports = router;
