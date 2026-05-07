const db = require('../Config/Db');

// GET /api/movements
exports.getAll = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT m.*,
              a.species, a.breed,
              r.rfid_code,
              ff.name AS from_farm_name,
              tf.name AS to_farm_name,
              CONCAT(u.first_name, ' ', u.last_name) AS approved_by_name
       FROM movements m
       JOIN animals a    ON a.id = m.animal_id
       LEFT JOIN rfid_tags r ON r.id = a.rfid_tag_id
       JOIN farms ff     ON ff.id = m.from_farm_id
       JOIN farms tf     ON tf.id = m.to_farm_id
       LEFT JOIN users u ON u.id = m.approved_by
       ORDER BY m.created_at DESC`
    );
    return res.json(rows);
  } catch (err) {
    console.error('[movements.getAll]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// GET /api/movements/:id
exports.getById = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT m.*,
              a.species, a.breed,
              r.rfid_code,
              ff.name AS from_farm_name,
              tf.name AS to_farm_name,
              CONCAT(u.first_name, ' ', u.last_name) AS approved_by_name
       FROM movements m
       JOIN animals a    ON a.id = m.animal_id
       LEFT JOIN rfid_tags r ON r.id = a.rfid_tag_id
       JOIN farms ff     ON ff.id = m.from_farm_id
       JOIN farms tf     ON tf.id = m.to_farm_id
       LEFT JOIN users u ON u.id = m.approved_by
       WHERE m.id = ?`, [req.params.id]
    );
    if (rows.length === 0)
      return res.status(404).json({ message: 'Mouvement non trouvé' });
    return res.json(rows[0]);
  } catch (err) {
    console.error('[movements.getById]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// POST /api/movements
exports.create = async (req, res) => {
  const { animalId, fromFarmId, toFarmId, reason, moveDate, notes } = req.body;

  if (!animalId || !fromFarmId || !toFarmId)
    return res.status(400).json({ message: 'animalId, fromFarmId et toFarmId sont obligatoires' });

  if (String(fromFarmId) === String(toFarmId))
    return res.status(400).json({ message: 'La ferme de départ et la ferme de destination doivent être différentes' });

  try {
    const [animals] = await db.query(
      'SELECT id, life_status FROM animals WHERE id = ?', [animalId]
    );
    if (animals.length === 0)
      return res.status(404).json({ message: 'Animal non trouvé' });
    if (animals[0].life_status !== 'Active')
      return res.status(400).json({ message: "Seuls les animaux en statut 'Active' peuvent être déplacés" });

    const [result] = await db.query(
      `INSERT INTO movements (animal_id, from_farm_id, to_farm_id, reason, move_date, approval_status, notes, created_at)
       VALUES (?, ?, ?, ?, ?, 'Pending', ?, NOW())`,
      [animalId, fromFarmId, toFarmId, reason || null, moveDate || null, notes || null]
    );

    return res.status(201).json({ message: 'Mouvement créé avec succès', movementId: result.insertId });
  } catch (err) {
    console.error('[movements.create]', err.message);
    if (err.message.includes('45000'))
      return res.status(400).json({ message: err.message });
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// PUT /api/movements/:id
exports.update = async (req, res) => {
  const { reason, moveDate, notes } = req.body;
  try {
    const [check] = await db.query('SELECT id, approval_status FROM movements WHERE id = ?', [req.params.id]);
    if (check.length === 0)
      return res.status(404).json({ message: 'Mouvement non trouvé' });
    if (check[0].approval_status !== 'Pending')
      return res.status(400).json({ message: 'Seuls les mouvements en attente peuvent être modifiés' });

    await db.query(
      `UPDATE movements SET
         reason    = COALESCE(?, reason),
         move_date = COALESCE(?, move_date),
         notes     = COALESCE(?, notes)
       WHERE id = ?`,
      [reason, moveDate, notes, req.params.id]
    );
    return res.json({ message: 'Mouvement modifié avec succès' });
  } catch (err) {
    console.error('[movements.update]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// PUT /api/movements/:id/approve
// Le trigger after_movement_approved met à jour animals.farm_id automatiquement
exports.approve = async (req, res) => {
  const { status } = req.body; // 'Approved' ou 'Rejected'
  const username = req.user.username;

  if (!['Approved', 'Rejected'].includes(status))
    return res.status(400).json({ message: "status doit être 'Approved' ou 'Rejected'" });

  try {
    const [check] = await db.query('SELECT id, approval_status FROM movements WHERE id = ?', [req.params.id]);
    if (check.length === 0)
      return res.status(404).json({ message: 'Mouvement non trouvé' });
    if (check[0].approval_status !== 'Pending')
      return res.status(400).json({ message: 'Ce mouvement a déjà été traité' });

    const [users] = await db.query('SELECT id FROM users WHERE username = ?', [username]);

    await db.query(
      'UPDATE movements SET approval_status = ?, approved_by = ? WHERE id = ?',
      [status, users[0].id, req.params.id]
    );

    return res.json({ message: `Mouvement ${status === 'Approved' ? 'approuvé' : 'rejeté'} avec succès` });
  } catch (err) {
    console.error('[movements.approve]', err.message);
    if (err.message.includes('45000'))
      return res.status(400).json({ message: err.message });
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// DELETE /api/movements/:id
exports.remove = async (req, res) => {
  try {
    const [check] = await db.query('SELECT id FROM movements WHERE id = ?', [req.params.id]);
    if (check.length === 0)
      return res.status(404).json({ message: 'Mouvement non trouvé' });

    await db.query('DELETE FROM movements WHERE id = ?', [req.params.id]);
    return res.json({ message: 'Mouvement supprimé avec succès' });
  } catch (err) {
    console.error('[movements.remove]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};
