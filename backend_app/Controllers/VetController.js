const db = require('../Config/Db');

// GET /api/vet/farms
exports.getAllFarms = async (req, res) => {
  try {
    const [farms] = await db.query(
      `SELECT f.*, u.first_name, u.last_name, COUNT(a.id) AS animal_count
       FROM farms f
       LEFT JOIN users u   ON u.id = f.owner_id
       LEFT JOIN animals a ON a.farm_id = f.id
       GROUP BY f.id ORDER BY f.name`
    );
    return res.json(farms);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// GET /api/vet/farm/:farmId/animals
exports.getAnimalsByFarm = async (req, res) => {
  const { farmId } = req.params;
  try {
    const [farms] = await db.query('SELECT id FROM farms WHERE id = ?', [farmId]);
    if (farms.length === 0)
      return res.status(404).json({ message: 'Ferme non trouvée' });

    const [animals] = await db.query(
      `SELECT a.*, r.rfid_code AS rfidCode
       FROM animals a
       LEFT JOIN rfid_tags r ON r.id = a.rfid_tag_id
       WHERE a.farm_id = ?`, [farmId]
    );
    return res.json(animals);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// GET /api/vet/scan/:rfidCode
exports.scanAnimal = async (req, res) => {
  const { rfidCode } = req.params;
  try {
    const [animals] = await db.query(
      `SELECT a.*, r.rfid_code, f.name AS farm_name
       FROM animals a
       JOIN rfid_tags r ON r.id = a.rfid_tag_id
       JOIN farms f     ON f.id = a.farm_id
       WHERE r.rfid_code = ?`, [rfidCode]
    );
    const animal = animals[0];
    if (!animal)
      return res.status(404).json({ message: `Animal non trouvé avec le tag : ${rfidCode}` });

    const [healthRecords] = await db.query(
      `SELECT hr.*, u.first_name, u.last_name
       FROM health_records hr
       LEFT JOIN users u ON u.id = hr.veterinarian_id
       WHERE hr.animal_id = ?
       ORDER BY hr.visit_date DESC`, [animal.id]
    );

    return res.json({
      rfidCode:     animal.rfid_code,
      species:      animal.species,
      breed:        animal.breed,
      gender:       animal.gender,
      lifeStatus:   animal.life_status,
      healthStatus: animal.health_status,
      farmName:     animal.farm_name,
      healthRecords,
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// POST /api/vet/health-record
exports.addHealthRecord = async (req, res) => {
  const username = req.user.username;
  // Support rfidCode ET rfidTag (Flutter envoie rfidTag)
  const rfidCode    = req.body.rfidCode || req.body.rfidTag;
  const recordType  = req.body.recordType;
  const diagnosis   = req.body.diagnosis;
  const treatmentPlan = req.body.treatmentPlan || req.body.treatment;

  if (!rfidCode || !recordType)
    return res.status(400).json({ message: 'rfidCode et recordType sont obligatoires' });

  try {
    const [animals] = await db.query(
      `SELECT a.id FROM animals a
       JOIN rfid_tags r ON r.id = a.rfid_tag_id
       WHERE r.rfid_code = ?`, [rfidCode]
    );
    if (animals.length === 0)
      return res.status(404).json({ message: 'Animal non trouvé' });

    const [vets] = await db.query('SELECT id FROM users WHERE username = ?', [username]);

    await db.query(
      `INSERT INTO health_records
         (animal_id, veterinarian_id, record_type, diagnosis, treatment_plan, visit_date)
       VALUES (?, ?, ?, ?, ?, NOW())`,
      [animals[0].id, vets[0].id, recordType, diagnosis || null, treatmentPlan || null]
    );

    return res.json({ message: 'Dossier médical ajouté avec succès' });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};