const Animal = require('../model/animal');

/**
 * Gère le scan d'un tag RFID depuis le mobile
 * Route: GET /api/animals/scan/:rfid
 */
exports.getanimalByScan = async (req, res) => {
    try {
        const rfidCode = req.params.rfid; // Récupère le code scanné
        const animal = await Animal.findByRfid(rfidCode);

        if (!animal) {
            return res.status(404).json({ 
                success: false, 
                message: "Aucun animal trouvé pour ce tag RFID." 
            });
        }

        // Renvoie toutes les infos nécessaires à l'affichage mobile 
        res.status(200).json({
            success: true,
            data: animal
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

/**
 * Enregistre un nouvel animal (Cycle de vie: Birth/Acquisition)
 * Route: POST /api/animals/register
 */
exports.registerNewanimal = async (req, res) => {
    try {
        // Les données envoyées par l'app Flutter via le body
        const animalId = await Animal.create(req.body);

        res.status(201).json({
            success: true,
            message: "animal enregistré avec succès et tag assigné.",
            animalId: animalId
        });
    } catch (error) {
        // Si le trigger SQL bloque (ex: tag défectueux), l'erreur sera captée ici
        res.status(400).json({ 
            success: false, 
            message: "Erreur d'enregistrement : " + error.message 
        });
    }
};

/**
 * Met à jour la ferme de l'animal (Mouvement)
 * Route: PATCH /api/animals/:id/move
 */
exports.moveanimal = async (req, res) => {
    try {
        const { id } = req.params;
        const { newFarmId } = req.body;

        await animal.updateFarm(id, newFarmId);

        // Note: Le trigger SQL "BeforeFarmChange" a déjà créé le log de mouvement en BDD
        res.status(200).json({
            success: true,
            message: "Mouvement enregistré et ferme mise à jour."
        });
    } catch (error) {
        res.status(400).json({ success: false, error: error.message });
    }
};

/**
 * Récupère l'historique de santé
 * Route: GET /api/animals/:id/health
 */
exports.getHealthHistory = async (req, res) => {
    try {
        const { id } = req.params;
        const history = await Animal.getHealthHistory(id);

        res.status(200).json({
            success: true,
            data: history // Liste des records types: Vaccination, Checkup, etc. [cite: 96]
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};