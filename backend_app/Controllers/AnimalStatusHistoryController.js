const db = require('../Config/Db');

// GET /api/animal-status-history
exports.getAll = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT ash.*,
              a.species, a.breed,
              r.rfid_code,
              CONCAT(u.first_name, ' ', u.last_name) AS changed_by_name
       FROM animal_status_history ash
       JOIN animals a     ON a.id = ash.animal_id
       LEFT JOIN rfid_tags r ON r.id = a.rfid_tag_id
       LEFT JOIN users u  ON u.id = ash.changed_by
       ORDER BY ash.changed_at DESC`
    );
    return res.json(rows);
  } catch (err) {
    console.error('[animalStatusHistory.getAll]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// GET /api/animal-status-history/animal/:animalId
exports.getByAnimal = async (req, res) => {
  try {
    const [check] = await db.query('SELECT id FROM animals WHERE id = ?', [req.params.animalId]);
    if (check.length === 0)
      return res.status(404).json({ message: 'Animal non trouvé' });

    const [rows] = await db.query(
      `SELECT ash.*,
              CONCAT(u.first_name, ' ', u.last_name) AS changed_by_name
       FROM animal_status_history ash
       LEFT JOIN users u ON u.id = ash.changed_by
       WHERE ash.animal_id = ?
       ORDER BY ash.changed_at DESC`, [req.params.animalId]
    );
    return res.json(rows);
  } catch (err) {
    console.error('[animalStatusHistory.getByAnimal]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};
