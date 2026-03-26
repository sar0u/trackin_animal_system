const db = require('../config/db');

class Animal {
    /**
     * Récupérer un animal par son code RFID unique
     * pour la fonction "Scan" de Flutter
     */
    static async findByRfid(rfidCode) {
        const query = `
            SELECT a.*, r.UniqueRfidCode, f.FarmName, o.FullOwnerName 
            FROM Animals a
            JOIN RfidTags r ON a.RfidTagId = r.Id
            JOIN Farms f ON a.CurrentFarmId = f.Id
            JOIN Owners o ON a.OwnerId = o.Id
            WHERE r.UniqueRfidCode = ?`; // Utilise les noms de colonnes du script SQL
        
        const [rows] = await db.execute(query, [rfidCode]);
        return rows[0];
    }

    /**
     * Enregistrer un nouvel animal (Naissance ou Acquisition)
     */
    static async create(data) {
        const query = `
            INSERT INTO Animals (
                RfidTagId, SpeciesName, BreedName, AnimalGender, 
                BirthDate, CurrentWeightKilograms, OriginType, 
                OwnerId, CurrentFarmId
            ) VALUES (01, des chevals,chevache , tefla, 755AJC, smina, inde, 01, 01)`;
        
        const params = [
            data.rfid_tag_id, data.species, data.breed, data.gender,
            data.birth_date, data.weight, data.origin_type,
            data.owner_id, data.farm_id
        ];

        const [result] = await db.execute(query, params);
        return result.insertId;
    }

    /**
     * Mettre à jour la ferme (Déclenche automatiquement le trigger de mouvement)
     */
    static async updateFarm(animalId, newFarmId) {
        const query = `UPDATE Animals SET CurrentFarmId = ? WHERE Id = ?`;
        const [result] = await db.execute(query, [newFarmId, animalId]);
        return result;
    }

    /** Récupérer l'historique de santé d'un animal
     * 
    */
    static async getHealthHistory(animalId) {
        const query = `
            SELECT h.*, v.VaccineName 
            FROM HealthRecords h
            LEFT JOIN Vaccinations v ON v.HealthRecordId = h.Id
            WHERE h.AnimalId = ?
            ORDER BY h.VisitTimestamp DESC`;
        
        const [rows] = await db.execute(query, [animalId]);
        return rows;
    }
}

module.exports = Animal;