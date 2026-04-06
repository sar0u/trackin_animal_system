<template>
  <header class="top-bar">
    <div class="search-box">
      <i class="fas fa-search"></i>
      <input type="text" placeholder="Rechercher un animal ID...">
    </div>
    <div class="user-profile">
      <div class="notif-icon"><i class="far fa-bell"></i><span class="dot"></span></div>
      <div class="profile-info">
        <span class="p-name">Admin_12</span>
        <span class="p-role">Farm Administrator</span>
      </div>
      <img src="https://ui-avatars.com/api/?name=Admin+12&background=2ecc71&color=fff" class="avatar">
    </div>
  </header>
</template>

<style scoped>
.top-bar {
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
}
.search-box {
  background: #f1f5f9;
  padding: 8px 15px;
  border-radius: 8px;
  width: 500px;
  display: flex;
  align-items: center;
  gap: 10px;
}
.search-box input {
  background: transparent;
  border: none;
  outline: none;
  width: 100%;
  font-size: 13px;
}
.user-profile { display: flex; align-items: center; gap: 20px; }
.avatar { width: 35px; border-radius: 50%; }
.p-name { display: block; font-weight: 700; font-size: 13px; text-align: right;}
.p-role { display: block; font-size: 11px; color: #00d432; font-weight: 600; }
</style>