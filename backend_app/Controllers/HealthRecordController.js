const db = require('../Config/Db');

// GET /api/health-records
exports.getAll = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT hr.*,
              a.species, a.breed,
              r.rfid_code,
              CONCAT(u.first_name, ' ', u.last_name) AS vet_name
       FROM health_records hr
       JOIN animals a     ON a.id = hr.animal_id
       LEFT JOIN rfid_tags r ON r.id = a.rfid_tag_id
       LEFT JOIN users u  ON u.id = hr.veterinarian_id
       ORDER BY hr.visit_date DESC`
    );
    return res.json(rows);
  } catch (err) {
    console.error('[healthRecords.getAll]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// GET /api/health-records/:id
exports.getById = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT hr.*,
              a.species, a.breed,
              r.rfid_code,
              CONCAT(u.first_name, ' ', u.last_name) AS vet_name
       FROM health_records hr
       JOIN animals a     ON a.id = hr.animal_id
       LEFT JOIN rfid_tags r ON r.id = a.rfid_tag_id
       LEFT JOIN users u  ON u.id = hr.veterinarian_id
       WHERE hr.id = ?`, [req.params.id]
    );
    if (rows.length === 0)
      return res.status(404).json({ message: 'Dossier médical non trouvé' });
    return res.json(rows[0]);
  } catch (err) {
    console.error('[healthRecords.getById]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// GET /api/health-records/animal/:animalId
exports.getByAnimal = async (req, res) => {
  try {
    const [check] = await db.query('SELECT id FROM animals WHERE id = ?', [req.params.animalId]);
    if (check.length === 0)
      return res.status(404).json({ message: 'Animal non trouvé' });

    const [rows] = await db.query(
      `SELECT hr.*,
              CONCAT(u.first_name, ' ', u.last_name) AS vet_name
       FROM health_records hr
       LEFT JOIN users u ON u.id = hr.veterinarian_id
       WHERE hr.animal_id = ?
       ORDER BY hr.visit_date DESC`, [req.params.animalId]
    );
    return res.json(rows);
  } catch (err) {
    console.error('[healthRecords.getByAnimal]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// POST /api/health-records
exports.create = async (req, res) => {
  const username = req.user.username;
  const {
    animalId, recordType, diagnosis, symptoms,
    treatmentPlan, visitDate, nextVisitDate, notes
  } = req.body;

  if (!animalId || !recordType)
    return res.status(400).json({ message: 'animalId et recordType sont obligatoires' });

  const validTypes = ['Vaccination', 'Treatment', 'Disease', 'Checkup', 'Surgery', 'LabTest', 'Injury'];
  if (!validTypes.includes(recordType))
    return res.status(400).json({ message: `recordType invalide. Valeurs acceptées : ${validTypes.join(', ')}` });

  try {
    const [animals] = await db.query('SELECT id FROM animals WHERE id = ?', [animalId]);
    if (animals.length === 0)
      return res.status(404).json({ message: 'Animal non trouvé' });

    const [vets] = await db.query('SELECT id FROM users WHERE username = ?', [username]);

    const [result] = await db.query(
      `INSERT INTO health_records
         (animal_id, veterinarian_id, record_type, diagnosis, symptoms, treatment_plan,
          visit_date, next_visit_date, notes, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())`,
      [
        animalId, vets[0].id, recordType,
        diagnosis || null, symptoms || null, treatmentPlan || null,
        visitDate || null, nextVisitDate || null, notes || null
      ]
    );

    return res.status(201).json({ message: 'Dossier médical créé avec succès', recordId: result.insertId });
  } catch (err) {
    console.error('[healthRecords.create]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// PUT /api/health-records/:id
exports.update = async (req, res) => {
  const {
    recordType, diagnosis, symptoms, treatmentPlan,
    visitDate, nextVisitDate, isValidated, notes
  } = req.body;

  try {
    const [check] = await db.query('SELECT id FROM health_records WHERE id = ?', [req.params.id]);
    if (check.length === 0)
      return res.status(404).json({ message: 'Dossier médical non trouvé' });

    await db.query(
      `UPDATE health_records SET
         record_type     = COALESCE(?, record_type),
         diagnosis       = COALESCE(?, diagnosis),
         symptoms        = COALESCE(?, symptoms),
         treatment_plan  = COALESCE(?, treatment_plan),
         visit_date      = COALESCE(?, visit_date),
         next_visit_date = COALESCE(?, next_visit_date),
         is_validated    = COALESCE(?, is_validated),
         notes           = COALESCE(?, notes),
         updated_at      = NOW()
       WHERE id = ?`,
      [
        recordType, diagnosis, symptoms, treatmentPlan,
        visitDate, nextVisitDate,
        isValidated !== undefined ? isValidated : null,
        notes, req.params.id
      ]
    );

    return res.json({ message: 'Dossier médical modifié avec succès' });
  } catch (err) {
    console.error('[healthRecords.update]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// DELETE /api/health-records/:id
exports.remove = async (req, res) => {
  try {
    const [check] = await db.query('SELECT id FROM health_records WHERE id = ?', [req.params.id]);
    if (check.length === 0)
      return res.status(404).json({ message: 'Dossier médical non trouvé' });

    await db.query('DELETE FROM health_records WHERE id = ?', [req.params.id]);
    return res.json({ message: 'Dossier médical supprimé avec succès' });
  } catch (err) {
    console.error('[healthRecords.remove]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};
