const db = require('../Config/Db');

// GET /api/farms
exports.getAll = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT f.*,
              CONCAT(u.first_name, ' ', u.last_name) AS owner_name,
              u.username AS owner_username,
              COUNT(a.id) AS animal_count
       FROM farms f
       LEFT JOIN users u   ON u.id = f.owner_id
       LEFT JOIN animals a ON a.farm_id = f.id
       GROUP BY f.id
       ORDER BY f.name`
    );
    return res.json(rows);
  } catch (err) {
    console.error('[farms.getAll]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// GET /api/farms/:id
exports.getById = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT f.*,
              CONCAT(u.first_name, ' ', u.last_name) AS owner_name,
              u.username AS owner_username,
              COUNT(a.id) AS animal_count
       FROM farms f
       LEFT JOIN users u   ON u.id = f.owner_id
       LEFT JOIN animals a ON a.farm_id = f.id
       WHERE f.id = ?
       GROUP BY f.id`, [req.params.id]
    );
    if (rows.length === 0)
      return res.status(404).json({ message: 'Ferme non trouvée' });
    return res.json(rows[0]);
  } catch (err) {
    console.error('[farms.getById]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// POST /api/farms
exports.create = async (req, res) => {
  const username = req.user.username;
  const { name, location, latitude, longitude, capacity, status } = req.body;

  if (!name)
    return res.status(400).json({ message: 'Le nom de la ferme est obligatoire' });

  try {
    const [users] = await db.query('SELECT id FROM users WHERE username = ?', [username]);

    const [result] = await db.query(
      `INSERT INTO farms (owner_id, name, location, latitude, longitude, capacity, status, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, NOW(), NOW())`,
      [
        users[0].id, name,
        location || null, latitude || null, longitude || null,
        capacity || null, status || 'Active'
      ]
    );

    return res.status(201).json({ message: 'Ferme créée avec succès', farmId: result.insertId });
  } catch (err) {
    console.error('[farms.create]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// PUT /api/farms/:id
exports.update = async (req, res) => {
  const username = req.user.username;
  const { name, location, latitude, longitude, capacity, status, isVerified } = req.body;

  try {
    const [users] = await db.query('SELECT id, role FROM users WHERE username = ?', [username]);
    const user = users[0];

    const [check] = await db.query('SELECT id, owner_id FROM farms WHERE id = ?', [req.params.id]);
    if (check.length === 0)
      return res.status(404).json({ message: 'Ferme non trouvée' });

    // Seul le propriétaire ou un admin peut modifier
    if (user.role !== 'Administrator' && check[0].owner_id !== user.id)
      return res.status(403).json({ message: 'Accès refusé : vous ne possédez pas cette ferme' });

    await db.query(
      `UPDATE farms SET
         name        = COALESCE(?, name),
         location    = COALESCE(?, location),
         latitude    = COALESCE(?, latitude),
         longitude   = COALESCE(?, longitude),
         capacity    = COALESCE(?, capacity),
         status      = COALESCE(?, status),
         is_verified = COALESCE(?, is_verified),
         updated_at  = NOW()
       WHERE id = ?`,
      [name, location, latitude, longitude, capacity, status,
       isVerified !== undefined ? (isVerified ? 1 : 0) : null,
       req.params.id]
    );

    return res.json({ message: 'Ferme modifiée avec succès' });
  } catch (err) {
    console.error('[farms.update]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// DELETE /api/farms/:id
exports.remove = async (req, res) => {
  try {
    const [check] = await db.query('SELECT id FROM farms WHERE id = ?', [req.params.id]);
    if (check.length === 0)
      return res.status(404).json({ message: 'Ferme non trouvée' });

    await db.query('DELETE FROM farms WHERE id = ?', [req.params.id]);
    return res.json({ message: 'Ferme supprimée avec succès' });
  } catch (err) {
    console.error('[farms.remove]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};
