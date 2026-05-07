const db = require('../Config/Db');

// GET /api/rfid-tags
exports.getAll = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT r.*,
              a.id AS animal_id, a.species, a.breed,
              f.name AS farm_name
       FROM rfid_tags r
       LEFT JOIN animals a ON a.rfid_tag_id = r.id AND a.life_status = 'Active'
       LEFT JOIN farms f   ON f.id = a.farm_id
       ORDER BY r.created_at DESC`
    );
    return res.json(rows);
  } catch (err) {
    console.error('[rfidTags.getAll]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// GET /api/rfid-tags/:id
exports.getById = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT r.*,
              a.id AS animal_id, a.species, a.breed,
              f.name AS farm_name
       FROM rfid_tags r
       LEFT JOIN animals a ON a.rfid_tag_id = r.id AND a.life_status = 'Active'
       LEFT JOIN farms f   ON f.id = a.farm_id
       WHERE r.id = ?`, [req.params.id]
    );
    if (rows.length === 0)
      return res.status(404).json({ message: 'Tag RFID non trouvé' });
    return res.json(rows[0]);
  } catch (err) {
    console.error('[rfidTags.getById]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// POST /api/rfid-tags
exports.create = async (req, res) => {
  const { rfidCode, tagType } = req.body;

  if (!rfidCode)
    return res.status(400).json({ message: 'rfidCode est obligatoire' });

  const validTypes = ['UHF', 'NFC'];
  if (tagType && !validTypes.includes(tagType))
    return res.status(400).json({ message: `tagType invalide. Valeurs : ${validTypes.join(', ')}` });

  try {
    const [existing] = await db.query('SELECT id FROM rfid_tags WHERE rfid_code = ?', [rfidCode]);
    if (existing.length > 0)
      return res.status(409).json({ message: 'Ce code RFID existe déjà' });

    const [result] = await db.query(
      `INSERT INTO rfid_tags (rfid_code, tag_type, tag_status, created_at)
       VALUES (?, ?, 'InStock', NOW())`,
      [rfidCode, tagType || 'UHF']
    );

    return res.status(201).json({ message: 'Tag RFID créé avec succès', tagId: result.insertId });
  } catch (err) {
    console.error('[rfidTags.create]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// PUT /api/rfid-tags/:id
exports.update = async (req, res) => {
  const { tagStatus, tagType } = req.body;
  const validStatuses = ['InStock', 'Assigned', 'Defective', 'Lost'];
  const validTypes    = ['UHF', 'NFC'];

  if (tagStatus && !validStatuses.includes(tagStatus))
    return res.status(400).json({ message: `tagStatus invalide. Valeurs : ${validStatuses.join(', ')}` });
  if (tagType && !validTypes.includes(tagType))
    return res.status(400).json({ message: `tagType invalide. Valeurs : ${validTypes.join(', ')}` });

  try {
    const [check] = await db.query('SELECT id FROM rfid_tags WHERE id = ?', [req.params.id]);
    if (check.length === 0)
      return res.status(404).json({ message: 'Tag RFID non trouvé' });

    await db.query(
      `UPDATE rfid_tags SET
         tag_status = COALESCE(?, tag_status),
         tag_type   = COALESCE(?, tag_type)
       WHERE id = ?`,
      [tagStatus, tagType, req.params.id]
    );

    return res.json({ message: 'Tag RFID modifié avec succès' });
  } catch (err) {
    console.error('[rfidTags.update]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// DELETE /api/rfid-tags/:id
exports.remove = async (req, res) => {
  try {
    const [check] = await db.query('SELECT id, tag_status FROM rfid_tags WHERE id = ?', [req.params.id]);
    if (check.length === 0)
      return res.status(404).json({ message: 'Tag RFID non trouvé' });
    if (check[0].tag_status === 'Assigned')
      return res.status(400).json({ message: 'Impossible de supprimer un tag actuellement assigné à un animal' });

    await db.query('DELETE FROM rfid_tags WHERE id = ?', [req.params.id]);
    return res.json({ message: 'Tag RFID supprimé avec succès' });
  } catch (err) {
    console.error('[rfidTags.remove]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};
