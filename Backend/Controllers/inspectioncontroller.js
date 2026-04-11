// Controllers/inspectioncontroller.js
const db = require('../config/db');


exports.getAllInspections = async (req, res) => {
    try {
        const [rows] = await db.execute('SELECT * FROM Inspections ORDER BY InspectionDate DESC');
        res.json({ success: true, data: rows });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.createInspection = async (req, res) => {
    try {
        const { 
            animalId, farmId, latitude, longitude, 
            locationDescription, result, fraudType, notes 
        } = req.body;
        
        const inspectorId = req.user.id;

        const query = `
            INSERT INTO Inspections 
            (InspectorId, AnimalId, FarmId, InspectionDate, Latitude, Longitude, 
             LocationDescription, Result, FraudType, Status, Notes) 
            VALUES (?, ?, ?, NOW(), ?, ?, ?, ?, ?, 'Pending', ?)`;
        
        const [resultRow] = await db.execute(query, [
            inspectorId, animalId || null, farmId || null, 
            latitude, longitude, locationDescription, 
            result, fraudType || 'None', notes
        ]);

        res.status(201).json({ 
            success: true, 
            message: "Inspection enregistrée", 
            inspectionId: resultRow.insertId 
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};