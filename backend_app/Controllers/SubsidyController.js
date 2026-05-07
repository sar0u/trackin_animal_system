const db = require('../Config/Db');

// GET /api/subsidies
exports.getAll = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT s.*,
              a.species, a.breed,
              r.rfid_code,
              CONCAT(u.first_name, ' ', u.last_name) AS approved_by_name
       FROM subsidies s
       LEFT JOIN animals a   ON a.id = s.animal_id
       LEFT JOIN rfid_tags r ON r.id = a.rfid_tag_id
       LEFT JOIN users u     ON u.id = s.approved_by
       ORDER BY s.created_at DESC`
    );
    return res.json(rows);
  } catch (err) {
    console.error('[subsidies.getAll]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// GET /api/subsidies/:id
exports.getById = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT s.*,
              a.species, a.breed,
              r.rfid_code,
              CONCAT(u.first_name, ' ', u.last_name) AS approved_by_name
       FROM subsidies s
       LEFT JOIN animals a   ON a.id = s.animal_id
       LEFT JOIN rfid_tags r ON r.id = a.rfid_tag_id
       LEFT JOIN users u     ON u.id = s.approved_by
       WHERE s.id = ?`, [req.params.id]
    );
    if (rows.length === 0)
      return res.status(404).json({ message: 'Subvention non trouvée' });
    return res.json(rows[0]);
  } catch (err) {
    console.error('[subsidies.getById]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// POST /api/subsidies
exports.create = async (req, res) => {
  const { animalId, amount, subsidyType, notes } = req.body;

  if (!amount || !subsidyType)
    return res.status(400).json({ message: 'amount et subsidyType sont obligatoires' });

  if (Number(amount) <= 0)
    return res.status(400).json({ message: 'Le montant doit être supérieur à 0' });

  try {
    if (animalId) {
      const [check] = await db.query('SELECT id FROM animals WHERE id = ?', [animalId]);
      if (check.length === 0)
        return res.status(404).json({ message: 'Animal non trouvé' });
    }

    const [result] = await db.query(
      `INSERT INTO subsidies (animal_id, amount, subsidy_type, status, request_date, notes, created_at, updated_at)
       VALUES (?, ?, ?, 'Pending', NOW(), ?, NOW(), NOW())`,
      [animalId || null, amount, subsidyType, notes || null]
    );

    return res.status(201).json({ message: 'Subvention créée avec succès', subsidyId: result.insertId });
  } catch (err) {
    console.error('[subsidies.create]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// PUT /api/subsidies/:id
exports.update = async (req, res) => {
  const { amount, subsidyType, notes } = req.body;

  try {
    const [check] = await db.query('SELECT id, status FROM subsidies WHERE id = ?', [req.params.id]);
    if (check.length === 0)
      return res.status(404).json({ message: 'Subvention non trouvée' });
    if (check[0].status !== 'Pending')
      return res.status(400).json({ message: 'Seules les subventions en attente peuvent être modifiées' });

    await db.query(
      `UPDATE subsidies SET
         amount       = COALESCE(?, amount),
         subsidy_type = COALESCE(?, subsidy_type),
         notes        = COALESCE(?, notes),
         updated_at   = NOW()
       WHERE id = ?`,
      [amount, subsidyType, notes, req.params.id]
    );

    return res.json({ message: 'Subvention modifiée avec succès' });
  } catch (err) {
    console.error('[subsidies.update]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// PUT /api/subsidies/:id/status
// Transitions : Pending → Approved → Paid  ou  Pending/Approved → Rejected
exports.updateStatus = async (req, res) => {
  const { status } = req.body;
  const username = req.user.username;
  const validStatuses = ['Pending', 'Approved', 'Rejected', 'Paid'];

  if (!validStatuses.includes(status))
    return res.status(400).json({ message: `status invalide. Valeurs acceptées : ${validStatuses.join(', ')}` });

  try {
    const [rows] = await db.query('SELECT id, status FROM subsidies WHERE id = ?', [req.params.id]);
    if (rows.length === 0)
      return res.status(404).json({ message: 'Subvention non trouvée' });

    const [users] = await db.query('SELECT id FROM users WHERE username = ?', [username]);

    let extraFields = 'updated_at = NOW()';
    const params = [];

    if (status === 'Approved') {
      extraFields += ', approved_date = NOW(), approved_by = ?';
      params.push(users[0].id);
    } else if (status === 'Paid') {
      extraFields += ', paid_date = NOW()';
    }

    params.push(status, req.params.id);
    await db.query(`UPDATE subsidies SET ${extraFields}, status = ? WHERE id = ?`, params);

    return res.json({ message: `Statut mis à jour : ${status}` });
  } catch (err) {
    console.error('[subsidies.updateStatus]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// DELETE /api/subsidies/:id
exports.remove = async (req, res) => {
  try {
    const [check] = await db.query('SELECT id FROM subsidies WHERE id = ?', [req.params.id]);
    if (check.length === 0)
      return res.status(404).json({ message: 'Subvention non trouvée' });

    await db.query('DELETE FROM subsidies WHERE id = ?', [req.params.id]);
    return res.json({ message: 'Subvention supprimée avec succès' });
  } catch (err) {
    console.error('[subsidies.remove]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};
