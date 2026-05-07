const db = require('../Config/Db');

// GET /api/scan-sessions
exports.getAll = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT ss.*,
              f.name AS farm_name,
              CONCAT(u.first_name, ' ', u.last_name) AS controller_name
       FROM scan_sessions ss
       JOIN farms f  ON f.id = ss.farm_id
       JOIN users u  ON u.id = ss.controller_id
       ORDER BY ss.session_date DESC`
    );
    return res.json(rows);
  } catch (err) {
    console.error('[scanSessions.getAll]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// GET /api/scan-sessions/:id
exports.getById = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT ss.*,
              f.name AS farm_name,
              CONCAT(u.first_name, ' ', u.last_name) AS controller_name
       FROM scan_sessions ss
       JOIN farms f  ON f.id = ss.farm_id
       JOIN users u  ON u.id = ss.controller_id
       WHERE ss.id = ?`, [req.params.id]
    );
    if (rows.length === 0)
      return res.status(404).json({ message: 'Session de scan non trouvée' });

    // Récupérer aussi les tags scannés pendant cette session
    const [tags] = await db.query(
      `SELECT st.*, r.rfid_code, r.tag_status
       FROM scanned_tags st
       JOIN rfid_tags r ON r.id = st.tag_id
       WHERE st.scan_session_id = ?`, [req.params.id]
    );

    return res.json({ ...rows[0], scannedTags: tags });
  } catch (err) {
    console.error('[scanSessions.getById]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// POST /api/scan-sessions
exports.create = async (req, res) => {
  const username = req.user.username;
  const { farmId, totalScanned, totalRegistered, isConsistent, notes, scannedTagCodes } = req.body;

  if (!farmId)
    return res.status(400).json({ message: 'farmId est obligatoire' });

  try {
    const [farms] = await db.query('SELECT id FROM farms WHERE id = ?', [farmId]);
    if (farms.length === 0)
      return res.status(404).json({ message: 'Ferme non trouvée' });

    const [users] = await db.query('SELECT id FROM users WHERE username = ?', [username]);

    const scanned    = Number(totalScanned)    || 0;
    const registered = Number(totalRegistered) || 0;

    const [result] = await db.query(
      `INSERT INTO scan_sessions
         (controller_id, farm_id, session_date, total_scanned, total_registered,
          is_consistent, status, notes, created_at)
       VALUES (?, ?, NOW(), ?, ?, ?, 'Pending', ?, NOW())`,
      [users[0].id, farmId, scanned, registered, isConsistent ? 1 : 0, notes || null]
    );

    const sessionId = result.insertId;

    // Lier les tags scannés si fournis
    if (Array.isArray(scannedTagCodes) && scannedTagCodes.length > 0) {
      for (const code of scannedTagCodes) {
        const [tags] = await db.query('SELECT id FROM rfid_tags WHERE rfid_code = ?', [code]);
        if (tags.length > 0) {
          await db.query(
            'INSERT IGNORE INTO scanned_tags (scan_session_id, tag_id) VALUES (?, ?)',
            [sessionId, tags[0].id]
          );
        }
      }
    }

    return res.status(201).json({ message: 'Session de scan créée avec succès', sessionId });
  } catch (err) {
    console.error('[scanSessions.create]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// PUT /api/scan-sessions/:id
exports.update = async (req, res) => {
  const { status, notes, isConsistent } = req.body;
  const validStatuses = ['Pending', 'Confirmed', 'Disputed'];

  if (status && !validStatuses.includes(status))
    return res.status(400).json({ message: `status invalide. Valeurs acceptées : ${validStatuses.join(', ')}` });

  try {
    const [check] = await db.query('SELECT id FROM scan_sessions WHERE id = ?', [req.params.id]);
    if (check.length === 0)
      return res.status(404).json({ message: 'Session de scan non trouvée' });

    const confirmedAt = status === 'Confirmed' ? 'confirmed_at = NOW(),' : '';

    await db.query(
      `UPDATE scan_sessions SET
         ${confirmedAt}
         status       = COALESCE(?, status),
         notes        = COALESCE(?, notes),
         is_consistent = COALESCE(?, is_consistent)
       WHERE id = ?`,
      [status, notes, isConsistent !== undefined ? (isConsistent ? 1 : 0) : null, req.params.id]
    );

    return res.json({ message: 'Session de scan mise à jour avec succès' });
  } catch (err) {
    console.error('[scanSessions.update]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// DELETE /api/scan-sessions/:id
exports.remove = async (req, res) => {
  try {
    const [check] = await db.query('SELECT id FROM scan_sessions WHERE id = ?', [req.params.id]);
    if (check.length === 0)
      return res.status(404).json({ message: 'Session de scan non trouvée' });

    await db.query('DELETE FROM scan_sessions WHERE id = ?', [req.params.id]);
    return res.json({ message: 'Session de scan supprimée avec succès' });
  } catch (err) {
    console.error('[scanSessions.remove]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};
