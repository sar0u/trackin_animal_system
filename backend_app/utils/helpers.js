function maskEmail(email) {
    if (!email || !email.includes('@')) return '***';
    const [local, domain] = email.split('@');
    return (local.length <= 2 ? '***' : local[0] + '***') + '@' + domain;
  }
  
  module.exports = { maskEmail };  