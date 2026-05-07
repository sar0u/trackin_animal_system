const multer = require('multer');
const path   = require('path');
const fs     = require('fs');
const db     = require('../Config/Db');

const ALLOWED_TYPES = ['image/jpeg', 'image/png', 'image/webp'];
const MAX_IMAGES    = 5;
const MIN_IMAGES    = 2;

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const dir = path.join(process.env.UPLOAD_DIR || 'uploads/inspections', req.params.inspectionId);
    fs.mkdirSync(dir, { recursive: true });
    cb(null, dir);
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname).toLowerCase() || '.jpg';
    cb(null, `${Date.now()}-${Math.random().toString(36).slice(2)}${ext}`);
  },
});

exports.upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    if (ALLOWED_TYPES.includes(file.mimetype)) cb(null, true);
    else cb(new Error(`Type non autorisé : ${file.mimetype}`));
  },
});

// POST /api/inspection/:inspectionId/images
exports.uploadImages = async (req, res) => {
  const { inspectionId } = req.params;
  const files     = req.files;
  const imageType = req.query.imageType || 'Photo';

  if (!files || files.length < MIN_IMAGES || files.length > MAX_IMAGES) {
    files?.forEach(f => fs.unlinkSync(f.path));
    return res.status(400).json({ message: `Envoyez entre ${MIN_IMAGES} et ${MAX_IMAGES} images.` });
  }

  try {
    const [inspections] = await db.query('SELECT id FROM inspections WHERE id = ?', [inspectionId]);
    if (inspections.length === 0) {
      files.forEach(f => fs.unlinkSync(f.path));
      return res.status(404).json({ message: `Inspection introuvable : ${inspectionId}` });
    }

    const [countRows] = await db.query(
      'SELECT COUNT(*) AS cnt FROM inspection_images WHERE inspection_id = ?', [inspectionId]
    );
    if (countRows[0].cnt + files.length > MAX_IMAGES) {
      files.forEach(f => fs.unlinkSync(f.path));
      return res.status(400).json({
        message: `Maximum ${MAX_IMAGES} images par inspection.`,
      });
    }

    const baseUrl = process.env.BASE_URL || 'http://localhost:8000';
    const saved   = [];

    for (const file of files) {
      const imageUrl = `${baseUrl}/uploads/inspections/${inspectionId}/${file.filename}`;
      const [result] = await db.query(
        `INSERT INTO inspection_images (inspection_id, image_url, image_type) VALUES (?, ?, ?)`,
        [inspectionId, imageUrl, imageType]
      );
      saved.push({ id: result.insertId, imageUrl, imageType });
    }

    return res.json({ message: 'Images uploadées avec succès', count: saved.length, images: saved });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Erreur lors du stockage des fichiers.' });
  }
};

// GET /api/inspection/:inspectionId/images
exports.getImages = async (req, res) => {
  const { inspectionId } = req.params;
  try {
    const [inspections] = await db.query('SELECT id FROM inspections WHERE id = ?', [inspectionId]);
    if (inspections.length === 0)
      return res.status(404).json({ message: `Inspection introuvable : ${inspectionId}` });

    const [images] = await db.query(
      'SELECT * FROM inspection_images WHERE inspection_id = ? ORDER BY created_at ASC',
      [inspectionId]
    );
    return res.json(images);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

// DELETE /api/inspection/:inspectionId/images/:imageId
exports.deleteImage = async (req, res) => {
  const { imageId } = req.params;
  try {
    const [rows] = await db.query('SELECT * FROM inspection_images WHERE id = ?', [imageId]);
    if (rows.length === 0)
      return res.status(404).json({ message: `Image introuvable : ${imageId}` });

    const image    = rows[0];
    const filename = image.image_url.split('/').pop();
    const filePath = path.join(
      process.env.UPLOAD_DIR || 'uploads/inspections',
      String(image.inspection_id),
      filename
    );
    try { fs.unlinkSync(filePath); } catch (_) {}

    await db.query('DELETE FROM inspection_images WHERE id = ?', [imageId]);
    return res.json({ message: 'Image supprimée avec succès' });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};