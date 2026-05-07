const db = require('../Config/Db');

// GET /api/farmer/scan/:rfidCode
// Scanne un animal — vérifie qu'il appartient bien au farmer connecté
exports.scanAnimal = async (req, res) => {
  const { rfidCode } = req.params;
  const username     = req.user.username;
  try {
    const [farmers] = await db.query('SELECT * FROM users WHERE username = ?', [username]);
    const farmer    = farmers[0];
    if (!farmer) return res.status(401).json({ message: 'Non authentifié' });

    const [animals] = await db.query(
      `SELECT a.*, r.rfid_code, f.name AS farm_name, f.location AS farm_location
       FROM animals a
       JOIN rfid_tags r ON r.id = a.rfid_tag_id
       JOIN farms f     ON f.id = a.farm_id
       WHERE r.rfid_code = ?`, [rfidCode]
    );
    const animal = animals[0];

    if (!animal)
      return res.status(404).json({ message: `Animal non trouvé avec le tag : ${rfidCode}` });
    if (animal.owner_id !== farmer.id)
      return res.status(403).json({ message: "Cet animal n'appartient pas à votre ferme" });

    return res.json({
      id:           animal.id,
      rfidCode:     animal.rfid_code,
      species:      animal.species,
      breed:        animal.breed,
      gender:       animal.gender,
      birthDate:    animal.birth_date,
      weight:       animal.weight,
      notes:        animal.notes,
      lifeStatus:   animal.life_status,
      healthStatus: animal.health_status,
      farmName:     animal.farm_name,
      farmLocation: animal.farm_location,
    });
  } catch (err) {
    console.error('[scanAnimal]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// GET /api/farmer/animals
// Retourne tous les animaux de la ferme du farmer connecté
exports.getMyAnimals = async (req, res) => {
  const username = req.user.username;
  try {
    const [users] = await db.query('SELECT id FROM users WHERE username = ?', [username]);
    const farmer  = users[0];

    const [animals] = await db.query(
      `SELECT a.id, a.species, a.breed, a.gender, a.birth_date AS birthDate,
              a.weight, a.notes, a.life_status AS lifeStatus,
              a.health_status AS healthStatus,
              r.rfid_code AS rfidCode,
              f.name AS farmName, f.location AS farmLocation
       FROM animals a
       LEFT JOIN rfid_tags r ON r.id = a.rfid_tag_id
       LEFT JOIN farms f     ON f.id = a.farm_id
       WHERE a.owner_id = ?`, [farmer.id]
    );
    return res.json(animals);
  } catch (err) {
    console.error('[getMyAnimals]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// POST /api/farmer/animals
// Crée un animal dans la ferme unique du farmer
// Champs : species (obligatoire), gender, birthDate, weight, notes, rfidCode (optionnel)
// Retourne : id + rfidCode de l'animal créé
exports.createAnimal = async (req, res) => {
  const username = req.user.username;
  const { rfidCode, species, gender, birthDate, weight, notes } = req.body;

  if (!species)
    return res.status(400).json({ message: 'Le champ species est obligatoire' });

  try {
    const [users] = await db.query('SELECT id FROM users WHERE username = ?', [username]);
    const farmer  = users[0];

    // Un farmer n'a qu'une seule ferme — on la récupère automatiquement
    const [farms] = await db.query(
      'SELECT id FROM farms WHERE owner_id = ? LIMIT 1', [farmer.id]
    );
    if (farms.length === 0)
      return res.status(400).json({ message: 'Aucune ferme trouvée pour ce compte' });

    const farmId = farms[0].id;

    // Gérer le tag RFID (optionnel)
    let rfidTagId = null;
    if (rfidCode && rfidCode.trim() !== '') {
      const [existTag] = await db.query(
        'SELECT id FROM rfid_tags WHERE rfid_code = ?', [rfidCode.trim()]
      );
      if (existTag.length > 0) {
        rfidTagId = existTag[0].id;
      } else {
        const [newTag] = await db.query(
          `INSERT INTO rfid_tags (rfid_code, tag_type, tag_status) VALUES (?, 'UHF', 'Assigned')`,
          [rfidCode.trim()]
        );
        rfidTagId = newTag.insertId;
      }
    }

    const [result] = await db.query(
      `INSERT INTO animals
         (rfid_tag_id, owner_id, farm_id, species, gender, birth_date, weight, notes, life_status, health_status)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'Active', 'Healthy')`,
      [rfidTagId, farmer.id, farmId, species.trim(),
       gender || 'Unknown', birthDate || null, weight || null, notes || null]
    );

    return res.status(201).json({
      message: 'Animal créé avec succès',
      animal: {
        id:        result.insertId,
        rfidCode:  rfidCode?.trim() || null,
        species:   species.trim(),
        gender:    gender || 'Unknown',
        birthDate: birthDate || null,
        weight:    weight || null,
        notes:     notes || null,
      },
    });
  } catch (err) {
    console.error('[createAnimal]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// PUT /api/farmer/animals/:id
// Modifie un animal existant (ownership vérifiée)
exports.updateAnimal = async (req, res) => {
  const username = req.user.username;
  const animalId = req.params.id;
  const { species, breed, gender, birthDate, weight, notes, lifeStatus, healthStatus } = req.body;

  try {
    const [users] = await db.query('SELECT id FROM users WHERE username = ?', [username]);
    const [check] = await db.query(
      'SELECT id FROM animals WHERE id = ? AND owner_id = ?', [animalId, users[0].id]
    );
    if (check.length === 0)
      return res.status(404).json({ message: 'Animal non trouvé ou accès refusé' });

    await db.query(
      `UPDATE animals SET
         species       = COALESCE(?, species),
         breed         = COALESCE(?, breed),
         gender        = COALESCE(?, gender),
         birth_date    = COALESCE(?, birth_date),
         weight        = COALESCE(?, weight),
         notes         = COALESCE(?, notes),
         life_status   = COALESCE(?, life_status),
         health_status = COALESCE(?, health_status)
       WHERE id = ?`,
      [species, breed, gender, birthDate, weight, notes, lifeStatus, healthStatus, animalId]
    );

    return res.json({ message: 'Animal modifié avec succès' });
  } catch (err) {
    console.error('[updateAnimal]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// DELETE /api/farmer/animals/:id
// Supprime un animal (ownership vérifiée)
exports.deleteAnimal = async (req, res) => {
  const username = req.user.username;
  const animalId = req.params.id;

  try {
    const [users] = await db.query('SELECT id FROM users WHERE username = ?', [username]);
    const [check] = await db.query(
      'SELECT id FROM animals WHERE id = ? AND owner_id = ?', [animalId, users[0].id]
    );
    if (check.length === 0)
      return res.status(404).json({ message: 'Animal non trouvé ou accès refusé' });

    await db.query('DELETE FROM animals WHERE id = ?', [animalId]);
    return res.json({ message: 'Animal supprimé avec succès' });
  } catch (err) {
    console.error('[deleteAnimal]', err.message);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};