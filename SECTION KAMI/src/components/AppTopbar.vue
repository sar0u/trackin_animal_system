<template>
  <header class="topbar">
    <div class="search-bar">
      <i class="fas fa-search"></i>
      <input type="text" placeholder="Recherche globale...">
    </div>
    <div class="user-profile">
      <div class="notifications">
        <i class="far fa-bell icon"></i>
        <span class="badge"></span>
      </div>
      <div class="profile-info">
        <span class="name">Admin_1234</span>
        <span class="tag">SUPER ADMIN</span>
      </div>
      <img src="https://ui-avatars.com/api/?name=Admin&background=2ecc71&color=fff" alt="Avatar" class="avatar">
    </div>
  </header>
</template>

<style scoped>
.topbar {
  background: white;
  padding: 12px 40px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid #edf2f7;
  position: sticky;
  top: 0;
  z-index: 100;
  width: 100%;
  box-sizing: border-box;
  font-family: 'Inter', sans-serif;
}

.search-bar {
  background: #f1f5f9;
  padding: 10px 20px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  gap: 12px;
  width: 350px;
}

.search-bar input {
  border: none;
  background: transparent;
  outline: none;
  width: 100%;
  font-size: 14px;
}

.user-profile {
  display: flex;
  align-items: center;
  gap: 25px;
}

.notifications {
  position: relative;
  color: #a0aec0;
  font-size: 18px;
  cursor: pointer;
}

.notifications .badge {
  position: absolute;
  top: -2px;
  right: -2px;
  width: 8px;
  height: 8px;
  background: #e53e3e;
  border-radius: 50%;
  border: 2px solid white;
}

.profile-info {
  text-align: right;
}

.profile-info .name {
  display: block;
  font-weight: 700;
  font-size: 14px;
  color: #2d3748;
}

.profile-info .tag {
  font-size: 11px;
  color: #11D432;
  font-weight: bold;
  text-transform: uppercase;
}

.avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  border: 2px solid #2ecc71;
  object-fit: cover;
}
</style>