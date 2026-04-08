require('../db'); // Assure-toi que la connexion à la base de données est établie
exports.createReport = async (req, res) => {
    try {
        const { type, description, latitude, longitude } = req.body;
        const reporterId = req.user.id;

        const query = `
            INSERT INTO Reports (Type, Description, Latitude, Longitude, ReporterId, Status, CreatedAt) 
            VALUES (?, ?, ?, ?, ?, 'Pending', NOW())`;
        
        await db.execute(query, [type, description, latitude, longitude, reporterId]);

        res.status(201).json({ success: true, message: "Signalement enregistré" });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};