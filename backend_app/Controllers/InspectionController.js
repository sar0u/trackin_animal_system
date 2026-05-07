const db = require('../Config/Db');

// POST /api/inspection/verify-scan
// Scan UHF longue portée : compare les tags scannés vs ceux enregistrés dans la ferme
// Retourne le nombre d'animaux détectés, les tags inconnus, les tags manquants
exports.verifyScan = async (req, res) => {
  const { farmId, scannedTags } = req.body;

  if (!farmId || !Array.isArray(scannedTags))
    return res.status(400).json({ message: 'farmId (integer) et scannedTags (array) requis' });

  try {
    const [farms] = await db.query('SELECT * FROM farms WHERE id = ?', [farmId]);
    if (farms.length === 0)
      return res.status(404).json({ message: 'Ferme non trouvée' });

    const [animals] = await db.query(
      `SELECT r.rfid_code FROM animals a
       JOIN rfid_tags r ON r.id = a.rfid_tag_id
       WHERE a.farm_id = ?`, [farmId]
    );
    const registeredCodes = animals.map(a => a.rfid_code);
    const unknownTags     = scannedTags.filter(t => !registeredCodes.includes(t));
    const missingTags     = registeredCodes.filter(t => !scannedTags.includes(t));

    return res.json({
      farmName:        farms[0].name,
      registeredCount: registeredCodes.length,   // animaux enregistrés en BD
      scannedCount:    scannedTags.length,         // animaux détectés par le scan UHF
      difference:      registeredCodes.length - scannedTags.length,
      unknownTags,     // tags scannés mais pas en BD (animaux non déclarés)
      missingTags,     // tags en BD mais pas scannés (animaux absents ou mort)
      isConsistent:    unknownTags.length === 0 && missingTags.length === 0,
    });
  } catch (err) {
    console.error('[verifyScan]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// POST /api/inspection/confirm
// Confirme l'inventaire d'une ferme après vérification UHF
exports.confirmCheck = async (req, res) => {
  const { farmId } = req.body;
  const username   = req.user.username;

  if (!farmId)
    return res.status(400).json({ message: 'farmId requis' });

  try {
    const [farms] = await db.query('SELECT * FROM farms WHERE id = ?', [farmId]);
    if (farms.length === 0)
      return res.status(404).json({ message: 'Ferme non trouvée' });

    const [users]   = await db.query('SELECT id FROM users WHERE username = ?', [username]);
    const [animals] = await db.query(
      'SELECT COUNT(*) AS cnt FROM animals WHERE farm_id = ?', [farmId]
    );

    const [result] = await db.query(
      `INSERT INTO inspections
         (inspector_id, description, constat_type, result, status, scanned_count, registered_count, inspection_date)
       VALUES (?, ?, 'Inventaire', 'Conforme', 'Resolved', ?, ?, NOW())`,
      [users[0].id, `Inventaire confirmé — ${farms[0].name}`, animals[0].cnt, animals[0].cnt]
    );

    return res.json({
      message:      'Inventaire confirmé avec succès',
      farmName:     farms[0].name,
      animalCount:  animals[0].cnt,
      inspectionId: result.insertId,
    });
  } catch (err) {
    console.error('[confirmCheck]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// POST /api/inspection/declare
// Déclare un constat/inspection sur le terrain
exports.declare = async (req, res) => {
  const { description, constatType, result, animalId } = req.body;
  const username = req.user.username;

  if (!description || description.trim() === '')
    return res.status(400).json({ message: 'La description est obligatoire' });

  try {
    const [users]   = await db.query('SELECT id FROM users WHERE username = ?', [username]);
    const inspector = users[0];

    const [ins] = await db.query(
      `INSERT INTO inspections
         (inspector_id, animal_id, description, constat_type, result, status, inspection_date)
       VALUES (?, ?, ?, ?, ?, 'Pending', NOW())`,
      [inspector.id, animalId || null, description.trim(), constatType || 'General', result || 'Pending']
    );

    return res.json({ message: 'Inspection déclarée avec succès', inspectionId: ins.insertId });
  } catch (err) {
    console.error('[declare]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// GET /api/inspection/list
// Liste toutes les inspections (pour consultation)
exports.list = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT i.*, u.first_name, u.last_name
       FROM inspections i
       JOIN users u ON u.id = i.inspector_id
       ORDER BY i.created_at DESC`
    );
    return res.json(rows);
  } catch (err) {
    console.error('[list]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// GET /api/inspection/my
// Inspections de l'inspecteur connecté uniquement
exports.myInspections = async (req, res) => {
  const username = req.user.username;
  try {
    const [users] = await db.query('SELECT id FROM users WHERE username = ?', [username]);
    const [rows]  = await db.query(
      'SELECT * FROM inspections WHERE inspector_id = ? ORDER BY created_at DESC', [users[0].id]
    );
    return res.json(rows);
  } catch (err) {
    console.error('[myInspections]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// GET /api/inspection/:id
exports.getById = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT i.*,
              CONCAT(u.first_name, ' ', u.last_name) AS inspector_name,
              a.species, a.breed,
              r.rfid_code
       FROM inspections i
       JOIN users u       ON u.id = i.inspector_id
       LEFT JOIN animals a  ON a.id = i.animal_id
       LEFT JOIN rfid_tags r ON r.id = a.rfid_tag_id
       WHERE i.id = ?`, [req.params.id]
    );
    if (rows.length === 0)
      return res.status(404).json({ message: 'Inspection non trouvée' });
    return res.json(rows[0]);
  } catch (err) {
    console.error('[inspection.getById]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// GET /api/inspection/animal/:animalId
exports.getByAnimal = async (req, res) => {
  try {
    const [check] = await db.query('SELECT id FROM animals WHERE id = ?', [req.params.animalId]);
    if (check.length === 0)
      return res.status(404).json({ message: 'Animal non trouvé' });

    const [rows] = await db.query(
      `SELECT i.*,
              CONCAT(u.first_name, ' ', u.last_name) AS inspector_name
       FROM inspections i
       JOIN users u ON u.id = i.inspector_id
       WHERE i.animal_id = ?
       ORDER BY i.inspection_date DESC`, [req.params.animalId]
    );
    return res.json(rows);
  } catch (err) {
    console.error('[inspection.getByAnimal]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// PUT /api/inspection/:id/status
exports.updateStatus = async (req, res) => {
  const { status, result } = req.body;
  const username = req.user.username;
  const validStatuses = ['Pending', 'UnderReview', 'Resolved', 'Rejected'];
  const validResults  = ['Compliant', 'Fraud', 'Suspicious', 'Pending'];

  if (status && !validStatuses.includes(status))
    return res.status(400).json({ message: `status invalide. Valeurs : ${validStatuses.join(', ')}` });
  if (result && !validResults.includes(result))
    return res.status(400).json({ message: `result invalide. Valeurs : ${validResults.join(', ')}` });

  try {
    const [check] = await db.query('SELECT id FROM inspections WHERE id = ?', [req.params.id]);
    if (check.length === 0)
      return res.status(404).json({ message: 'Inspection non trouvée' });

    const [users] = await db.query('SELECT id FROM users WHERE username = ?', [username]);

    const resolvedAt = status === 'Resolved' ? ', resolved_at = NOW(), resolved_by = ' + users[0].id : '';

    await db.query(
      `UPDATE inspections SET
         status     = COALESCE(?, status),
         result     = COALESCE(?, result)
         ${resolvedAt},
         updated_at = NOW()
       WHERE id = ?`,
      [status, result, req.params.id]
    );

    return res.json({ message: 'Statut de l\'inspection mis à jour' });
  } catch (err) {
    console.error('[inspection.updateStatus]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// DELETE /api/inspection/:id
exports.remove = async (req, res) => {
  try {
    const [check] = await db.query('SELECT id FROM inspections WHERE id = ?', [req.params.id]);
    if (check.length === 0)
      return res.status(404).json({ message: 'Inspection non trouvée' });

    await db.query('DELETE FROM inspections WHERE id = ?', [req.params.id]);
    return res.json({ message: 'Inspection supprimée avec succès' });
  } catch (err) {
    console.error('[inspection.remove]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};