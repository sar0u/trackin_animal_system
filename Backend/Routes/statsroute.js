const express = require('express');
const router = express.Router();
const MetadataController = require('../Controllers/metadatacontroller');
const auth = require('../middleware/auth'); 


// ROUTES DASHBOARD
router.get('/api/dashboard/stats', auth, MetadataController.getDashboardStats);
router.get('/api/metadata/options', auth, MetadataController.getFormOptions);

// ROUTE RAPPORTS
router.get('/api/reports/activity', auth, async (req, res) => {
    const Metadata = require('../model/metadata');
    try {
        const report = await Metadata.getActivityReport(req.user.id);
        res.json({ success: true, data: report });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});


module.exports = router;