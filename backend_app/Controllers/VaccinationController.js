const db = require('../Config/Db');

// GET /api/vaccinations
exports.getAll = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT v.*,
              hr.record_type, hr.visit_date,
              a.species, a.breed,
              r.rfid_code,
              CONCAT(u.first_name, ' ', u.last_name) AS administered_by_name
       FROM vaccinations v
       JOIN health_records hr ON hr.id = v.health_record_id
       JOIN animals a         ON a.id = hr.animal_id
       LEFT JOIN rfid_tags r  ON r.id = a.rfid_tag_id
       LEFT JOIN users u      ON u.id = v.administered_by
       ORDER BY v.created_at DESC`
    );
    return res.json(rows);
  } catch (err) {
    console.error('[vaccinations.getAll]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// GET /api/vaccinations/:id
exports.getById = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT v.*,
              hr.record_type, hr.visit_date,
              a.species, a.breed,
              r.rfid_code,
              CONCAT(u.first_name, ' ', u.last_name) AS administered_by_name
       FROM vaccinations v
       JOIN health_records hr ON hr.id = v.health_record_id
       JOIN animals a         ON a.id = hr.animal_id
       LEFT JOIN rfid_tags r  ON r.id = a.rfid_tag_id
       LEFT JOIN users u      ON u.id = v.administered_by
       WHERE v.id = ?`, [req.params.id]
    );
    if (rows.length === 0)
      return res.status(404).json({ message: 'Vaccination non trouvée' });
    return res.json(rows[0]);
  } catch (err) {
    console.error('[vaccinations.getById]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// GET /api/vaccinations/record/:recordId
exports.getByRecord = async (req, res) => {
  try {
    const [check] = await db.query('SELECT id FROM health_records WHERE id = ?', [req.params.recordId]);
    if (check.length === 0)
      return res.status(404).json({ message: 'Dossier médical non trouvé' });

    const [rows] = await db.query(
      `SELECT v.*,
              CONCAT(u.first_name, ' ', u.last_name) AS administered_by_name
       FROM vaccinations v
       LEFT JOIN users u ON u.id = v.administered_by
       WHERE v.health_record_id = ?
       ORDER BY v.created_at DESC`, [req.params.recordId]
    );
    return res.json(rows);
  } catch (err) {
    console.error('[vaccinations.getByRecord]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// POST /api/vaccinations
exports.create = async (req, res) => {
  const username = req.user.username;
  const {
    healthRecordId, vaccineName, vaccineType, manufacturer,
    batchNumber, dose, expirationDate, nextDoseDate
  } = req.body;

  if (!healthRecordId || !vaccineName)
    return res.status(400).json({ message: 'healthRecordId et vaccineName sont obligatoires' });

  try {
    const [check] = await db.query('SELECT id FROM health_records WHERE id = ?', [healthRecordId]);
    if (check.length === 0)
      return res.status(404).json({ message: 'Dossier médical non trouvé' });

    const [vets] = await db.query('SELECT id FROM users WHERE username = ?', [username]);

    const [result] = await db.query(
      `INSERT INTO vaccinations
         (health_record_id, vaccine_name, vaccine_type, manufacturer, batch_number,
          dose, expiration_date, next_dose_date, administered_by, created_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())`,
      [
        healthRecordId, vaccineName,
        vaccineType || null, manufacturer || null, batchNumber || null,
        dose || null, expirationDate || null, nextDoseDate || null,
        vets[0].id
      ]
    );

    return res.status(201).json({ message: 'Vaccination enregistrée avec succès', vaccinationId: result.insertId });
  } catch (err) {
    console.error('[vaccinations.create]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// PUT /api/vaccinations/:id
exports.update = async (req, res) => {
  const {
    vaccineName, vaccineType, manufacturer,
    batchNumber, dose, expirationDate, nextDoseDate
  } = req.body;

  try {
    const [check] = await db.query('SELECT id FROM vaccinations WHERE id = ?', [req.params.id]);
    if (check.length === 0)
      return res.status(404).json({ message: 'Vaccination non trouvée' });

    await db.query(
      `UPDATE vaccinations SET
         vaccine_name    = COALESCE(?, vaccine_name),
         vaccine_type    = COALESCE(?, vaccine_type),
         manufacturer    = COALESCE(?, manufacturer),
         batch_number    = COALESCE(?, batch_number),
         dose            = COALESCE(?, dose),
         expiration_date = COALESCE(?, expiration_date),
         next_dose_date  = COALESCE(?, next_dose_date)
       WHERE id = ?`,
      [vaccineName, vaccineType, manufacturer, batchNumber, dose, expirationDate, nextDoseDate, req.params.id]
    );

    return res.json({ message: 'Vaccination modifiée avec succès' });
  } catch (err) {
    console.error('[vaccinations.update]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// DELETE /api/vaccinations/:id
exports.remove = async (req, res) => {
  try {
    const [check] = await db.query('SELECT id FROM vaccinations WHERE id = ?', [req.params.id]);
    if (check.length === 0)
      return res.status(404).json({ message: 'Vaccination non trouvée' });

    await db.query('DELETE FROM vaccinations WHERE id = ?', [req.params.id]);
    return res.json({ message: 'Vaccination supprimée avec succès' });
  } catch (err) {
    console.error('[vaccinations.remove]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};
