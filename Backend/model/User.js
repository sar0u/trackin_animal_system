const db = require('C:/Users/HP/atsback/config/db');
const bcrypt = require ('bcryptjs');


class User {
  static async findByEmail(email) {
    const [rows] = await db.execute( 'SELECT * FROM Users Where Email = ?', [email]);
    return rows[0]
  }
 static async create(userData) {
    const {FullOwnerName, Email, Password, UserRole, PhoneNumber} = userData;
    const salt= await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(Password, salt);

    const query =
        'INSERT INTO Users (FullOwnerName, Email, Password, UserRole, PhoneNumber) VALUES (?, ?, ?, ?, ?)';
    const [result] = await db.execute(query, [FullOwnerName, Email, hashedPassword, UserRole, PhoneNumber]);
    return result.insertId;

 }
 static async comparePassword(enteredPassword, hashedPassword){
    return await bcrypt.compare(enteredPassword, hashedPassword);
 }
}

module.exports = User;