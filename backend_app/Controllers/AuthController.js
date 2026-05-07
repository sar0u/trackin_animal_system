const bcrypt     = require('bcryptjs');
const jwt        = require('jsonwebtoken');
const db         = require('../Config/Db');
const { maskEmail } = require('../utils/helpers');

// POST /api/auth/login
exports.login = async (req, res) => {
  const { username, password } = req.body;
  if (!username || !password)
    return res.status(400).json({ message: 'Username et password requis' });

  try {
    const [rows] = await db.query('SELECT * FROM users WHERE username = ?', [username]);
    const user   = rows[0];

    if (!user || !(await bcrypt.compare(password, user.password)))
      return res.status(401).json({ message: 'Identifiant ou mot de passe incorrect' });

    if (!user.is_active)
      return res.status(403).json({ message: 'Compte désactivé' });

    const token = jwt.sign(
      { username: user.username, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '24h' }
    );

    // Récupérer la ferme du farmer
    let farmId = null, farmName = null;
    if (user.role === 'Farmer') {
      const [farms] = await db.query(
        'SELECT id, name FROM farms WHERE owner_id = ? LIMIT 1', [user.id]
      );
      if (farms.length > 0) { farmId = farms[0].id; farmName = farms[0].name; }
    }

    return res.json({
      token,
      role:     user.role,
      username: user.username,
      userId:   user.id,
      fullName: `${user.first_name} ${user.last_name}`,
      farmId,
      farmName,
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// POST /api/auth/register
exports.register = async (req, res) => {
  let { username, password, email, firstName, lastName, fullName, role, phone } = req.body;

  // Support fullName envoyé par Flutter
  if (fullName && (!firstName || !lastName)) {
    const parts = fullName.trim().split(' ');
    firstName = parts[0];
    lastName  = parts.slice(1).join(' ') || parts[0];
  }

  if (!username || !password || !email || !firstName || !lastName)
    return res.status(400).json({ message: 'Champs obligatoires manquants' });

  const validRoles = ['Farmer', 'Veterinarian', 'Inspector'];
  const userRole   = validRoles.includes(role) ? role : 'Farmer';

  try {
    const [existUser] = await db.query('SELECT id FROM users WHERE username = ?', [username]);
    if (existUser.length > 0)
      return res.status(400).json({ message: "Ce nom d'utilisateur est déjà pris" });

    const [existEmail] = await db.query('SELECT id FROM users WHERE email = ?', [email]);
    if (existEmail.length > 0)
      return res.status(400).json({ message: 'Cet email est déjà utilisé' });

    const hashedPwd = await bcrypt.hash(password, 10);
    const [result]  = await db.query(
      `INSERT INTO users (username, email, password, first_name, last_name, role, phone, is_active)
       VALUES (?, ?, ?, ?, ?, ?, ?, 1)`,
      [username, email, hashedPwd, firstName, lastName, userRole, phone || null]
    );

    if (userRole === 'Farmer') {
      await db.query(
        `INSERT INTO farms (owner_id, name, location, status) VALUES (?, ?, ?, 'Active')`,
        [result.insertId, `Ferme de ${firstName} ${lastName}`, 'À définir']
      );
    }

    return res.json({ message: 'Compte créé avec succès', username, role: userRole });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// POST /api/auth/forgot-password
exports.forgotPassword = async (req, res) => {
  const { identifier } = req.body;
  if (!identifier || identifier.trim() === '')
    return res.status(400).json({ message: 'Veuillez fournir un identifiant ou email' });

  try {
    const [rows] = await db.query(
      'SELECT * FROM users WHERE username = ? OR email = ?', [identifier, identifier]
    );
    if (rows.length === 0)
      return res.status(404).json({ message: 'Aucun compte trouvé' });

    const user = rows[0];
    return res.json({
      message:  'Compte trouvé. Vous pouvez réinitialiser votre mot de passe.',
      username: user.username,
      email:    maskEmail(user.email),
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// POST /api/auth/reset-password
exports.resetPassword = async (req, res) => {
  const { identifier, newPassword } = req.body;

  if (!newPassword || newPassword.length < 6)
    return res.status(400).json({ message: 'Le mot de passe doit contenir au moins 6 caractères' });

  try {
    const [rows] = await db.query(
      'SELECT * FROM users WHERE username = ? OR email = ?', [identifier, identifier]
    );
    if (rows.length === 0)
      return res.status(404).json({ message: 'Utilisateur non trouvé' });

    const hashed = await bcrypt.hash(newPassword, 10);
    await db.query('UPDATE users SET password = ? WHERE id = ?', [hashed, rows[0].id]);

    return res.json({ message: 'Mot de passe réinitialisé avec succès' });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};