// ==================== FIREBASE CONFIGURATION & INITIALIZATION ====================
const firebaseConfig = {
  apiKey: "AIzaSyCk0HXhKFCZ7RlshZ3Z9c2v6nB7IaNtKlA",
  authDomain: "hane-hackathon.firebaseapp.com",
  databaseURL: "https://hane-hackathon-default-rtdb.firebaseio.com",
  projectId: "hane-hackathon",
  storageBucket: "hane-hackathon.firebasestorage.app",
  messagingSenderId: "242189023598",
  appId: "1:242189023598:web:451183f8929c618915297f"
};

// Initialize Firebase
firebase.initializeApp(firebaseConfig);
const db = firebase.database();

// ==================== STATE VARIABLES ====================
let currentUser = null;
let employeesCache = [];
let tfaTimer = null;
let tfaCountdown = 30;

// ==================== UI ELEMENTS ====================
const authContainer = document.getElementById('auth-container');
const loginCard = document.getElementById('login-card');
const tfaCard = document.getElementById('tfa-card');
const dashboardContainer = document.getElementById('dashboard-container');

// Responsive UI elements
const sidebar = document.querySelector('.sidebar');
const btnSidebarToggle = document.getElementById('btn-sidebar-toggle');
const sidebarOverlay = document.getElementById('sidebar-overlay');

const loginForm = document.getElementById('login-form');
const loginEmail = document.getElementById('login-email');
const loginPassword = document.getElementById('login-password');
const loginError = document.getElementById('login-error');

const tfaForm = document.getElementById('tfa-form');
const tfaBoxes = document.querySelectorAll('.tfa-box');
const tfaError = document.getElementById('tfa-error');
const tfaEmailDisplay = document.getElementById('tfa-email-display');
const timerDisplay = document.getElementById('timer-sec');
const resendLink = document.getElementById('tfa-resend-link');

const menuItems = document.querySelectorAll('.menu-item');
const tabPanes = document.querySelectorAll('.tab-pane');
const pageTitle = document.getElementById('page-title');
const userDisplayName = document.getElementById('user-display-name');
const btnLogout = document.getElementById('btn-logout');

// CRM / Employees
const btnAddEmployee = document.getElementById('btn-add-employee');
const employeeSearch = document.getElementById('employee-search');
const employeeGrid = document.getElementById('employee-grid');
const employeeCountText = document.getElementById('employee-count');
const employeeModal = document.getElementById('employee-modal');
const employeeForm = document.getElementById('employee-form');
const empModalTitle = document.getElementById('employee-modal-title');
const btnSaveEmployee = document.getElementById('btn-save-employee');

// Payroll
const btnAddPayroll = document.getElementById('btn-add-payroll');
const payrollsGrid = document.getElementById('payrolls-grid');
const payrollModal = document.getElementById('payroll-modal');
const payrollForm = document.getElementById('payroll-form');
const payEmployeeSelect = document.getElementById('pay-employee');

// Lists/Tables
const approvalsList = document.getElementById('approvals-list');
const leavesTableBody = document.getElementById('leaves-table-body');
const logsTableBody = document.getElementById('logs-table-body');

// Modals close buttons
const closeModalButtons = document.querySelectorAll('.btn-close-modal');

// ==================== INITIALIZATION & EVENT LISTENERS ====================
document.addEventListener('DOMContentLoaded', () => {
  setupTfaInputs();
  setupTabNavigation();
  setupModals();
  setupMobileSidebar();
  
  // Login Form Submission
  loginForm.addEventListener('submit', (e) => {
    e.preventDefault();
    handleLogin();
  });

  // 2FA Verification Submission
  tfaForm.addEventListener('submit', (e) => {
    e.preventDefault();
    handleTfaVerification();
  });

  // Resend 2FA Code
  resendLink.addEventListener('click', (e) => {
    e.preventDefault();
    if (!resendLink.classList.contains('disabled')) {
      startTfaTimer();
      alert("Doğrulama kodu e-postanıza tekrar gönderildi (Simüle edildi).");
    }
  });

  // Logout
  btnLogout.addEventListener('click', () => {
    logout();
  });

  // CRM Search Input
  employeeSearch.addEventListener('input', () => {
    filterEmployees();
  });

  // Save/Create Employee Submit
  employeeForm.addEventListener('submit', (e) => {
    e.preventDefault();
    saveEmployee();
  });

  // Create Payroll Submit
  payrollForm.addEventListener('submit', (e) => {
    e.preventDefault();
    savePayroll();
  });
});

// ==================== AUTHENTICATION FLOW ====================

function handleLogin() {
  const email = loginEmail.value.trim();
  const password = loginPassword.value;

  loginError.classList.add('hidden');
  
  // Simple administrative credential validation mimicking the Flutter authentication
  if (email === 'admin@hane.org.tr' && password === '123456') {
    // Show 2FA Screen
    tfaEmailDisplay.textContent = email.replace(/(.{1})(.*)(@.*)/, "$1***$3");
    
    loginCard.classList.remove('active');
    setTimeout(() => {
      tfaCard.classList.add('active');
      tfaBoxes[0].focus();
      startTfaTimer();
    }, 200);
  } else {
    showError(loginError, "Hatalı e-posta adresi veya şifre! (İK Yönetici hesabı: admin@hane.org.tr / 123456)");
  }
}

function setupTfaInputs() {
  tfaBoxes.forEach((box, index) => {
    // Focus shift logic
    box.addEventListener('input', (e) => {
      const val = e.target.value;
      if (val.length === 1 && index < tfaBoxes.length - 1) {
        tfaBoxes[index + 1].removeAttribute('disabled');
        tfaBoxes[index + 1].focus();
      }
    });

    // Keyboard navigation (backspace)
    box.addEventListener('keydown', (e) => {
      if (e.key === 'Backspace' && box.value.length === 0 && index > 0) {
        tfaBoxes[index - 1].focus();
        tfaBoxes[index - 1].value = '';
      }
    });
  });
}

function startTfaTimer() {
  clearInterval(tfaTimer);
  tfaCountdown = 30;
  timerDisplay.textContent = tfaCountdown;
  resendLink.classList.add('disabled');

  tfaTimer = setInterval(() => {
    tfaCountdown--;
    timerDisplay.textContent = tfaCountdown;
    
    if (tfaCountdown <= 0) {
      clearInterval(tfaTimer);
      resendLink.classList.remove('disabled');
    }
  }, 1000);
}

function handleTfaVerification() {
  tfaError.classList.add('hidden');
  
  let enteredCode = '';
  tfaBoxes.forEach(box => enteredCode += box.value);

  // Accept any code for simulation, but check if all boxes are filled
  if (enteredCode.length === 6) {
    clearInterval(tfaTimer);
    
    // Simulate verification delay
    const btn = document.getElementById('btn-tfa-verify');
    const originalText = btn.innerHTML;
    btn.innerHTML = '<span>Doğrulanıyor...</span>';
    btn.disabled = true;

    setTimeout(() => {
      btn.innerHTML = originalText;
      btn.disabled = false;
      
      // Navigate to Dashboard
      authContainer.classList.add('hidden');
      dashboardContainer.classList.remove('hidden');
      
      currentUser = {
        name: "Zeynep Turan",
        email: "admin@hane.org.tr",
        role: "İK Çalışanı (Admin)",
        uid: "uid_admin"
      };

      userDisplayName.textContent = currentUser.name;
      
      // Start Realtime Database Listeners
      startDatabaseListeners();
      
      // Log sign-in
      writeLog(currentUser.name, "Sisteme giriş yapıldı (2FA Doğrulandı)", "Güvenlik");
    }, 800);
  } else {
    showError(tfaError, "Lütfen 6 haneli doğrulama kodunu eksiksiz girin.");
  }
}

function logout() {
  writeLog(currentUser ? currentUser.name : "İK Yönetici", "Sistemden güvenli çıkış yapıldı", "Güvenlik");
  currentUser = null;
  dashboardContainer.classList.add('hidden');
  authContainer.classList.remove('hidden');
  
  // Reset fields
  loginForm.reset();
  tfaForm.reset();
  tfaBoxes.forEach((box, i) => {
    box.value = '';
    if (i > 0) box.setAttribute('disabled', 'true');
  });

  tfaCard.classList.remove('active');
  loginCard.classList.add('active');
  
  closeMobileSidebar();
}

// Responsive Sidebar Helpers
function setupMobileSidebar() {
  if (!btnSidebarToggle || !sidebarOverlay || !sidebar) return;

  btnSidebarToggle.addEventListener('click', () => {
    sidebar.classList.add('open');
    sidebarOverlay.classList.add('active');
  });

  sidebarOverlay.addEventListener('click', () => {
    closeMobileSidebar();
  });
}

function closeMobileSidebar() {
  if (sidebar && sidebarOverlay) {
    sidebar.classList.remove('open');
    sidebarOverlay.classList.remove('active');
  }
}

function showError(element, msg) {
  element.textContent = msg;
  element.classList.remove('hidden');
}

// ==================== DASHBOARD FLOW ====================

function setupTabNavigation() {
  menuItems.forEach(item => {
    item.addEventListener('click', (e) => {
      e.preventDefault();
      
      // Toggle active states
      menuItems.forEach(i => i.classList.remove('active'));
      item.classList.add('active');

      const tabId = item.getAttribute('data-tab');
      tabPanes.forEach(pane => pane.classList.remove('active'));
      document.getElementById(`tab-${tabId}`).classList.add('active');

      // Update Topbar Title
      const labels = {
        'onaylar': 'Paylaşım Onayları',
        'crm': 'CRM / Çalışanlar',
        'bordrolar': 'Bordro Yönetimi',
        'izinler': 'İzin Talepleri',
        'degerlendirmeler': 'Yıl Sonu Değerlendirmeleri',
        'loglar': 'Sistem Logları'
      };
      pageTitle.textContent = labels[tabId] || 'Panel';
      
      closeMobileSidebar();
    });
  });
}

function setupModals() {
  // Open Add Employee Modal
  btnAddEmployee.addEventListener('click', () => {
    employeeForm.reset();
    document.getElementById('emp-uid').value = '';
    empModalTitle.textContent = "Yeni Çalışan Ekle";
    btnSaveEmployee.textContent = "Ekle";
    employeeModal.classList.add('active');
  });

  // Open Add Payroll Modal
  btnAddPayroll.addEventListener('click', () => {
    payrollForm.reset();
    populateEmployeeDropdown();
    payrollModal.classList.add('active');
  });

  // Close Modals
  closeModalButtons.forEach(btn => {
    btn.addEventListener('click', (e) => {
      e.preventDefault();
      employeeModal.classList.remove('active');
      payrollModal.classList.remove('active');
    });
  });
}

// ==================== DATABASE LISTENERS ====================

function startDatabaseListeners() {
  // 1. Listen to Announcements (Paylaşım Onayları)
  db.ref('announcements').on('value', (snapshot) => {
    const data = snapshot.val();
    renderPendingApprovals(data);
  });

  // 2. Listen to Users (CRM / Çalışanlar)
  db.ref('users').on('value', (snapshot) => {
    const data = snapshot.val();
    employeesCache = [];
    if (data) {
      if (Array.isArray(data)) {
        data.forEach((val, index) => {
          if (val) {
            employeesCache.push({ ...val, uid: index.toString() });
          }
        });
      } else {
        Object.keys(data).forEach(key => {
          employeesCache.push({ ...data[key], uid: key });
        });
      }
    }
    renderEmployees(employeesCache);
    employeeCountText.textContent = `${employeesCache.length} Kişi`;
  });

  // 3. Listen to Payrolls (Bordro Yönetimi)
  db.ref('payrolls').on('value', (snapshot) => {
    const data = snapshot.val();
    renderPayrolls(data);
  });

  // 4. Listen to Leave Requests (İzin Talepleri)
  db.ref('leaveRequests').on('value', (snapshot) => {
    const data = snapshot.val();
    renderLeaveRequests(data);
  });

  // 5. Listen to Logs (Sistem Logları)
  db.ref('logs').on('value', (snapshot) => {
    const data = snapshot.val();
    renderLogs(data);
  });

  // 6. Listen to Evaluations (Yıl Sonu Değerlendirmeleri)
  db.ref('evaluations').on('value', (snapshot) => {
    const data = snapshot.val();
    renderEvaluations(data);
  });
}

// ==================== RENDERERS ====================

// RENDER TAB 1: PAYLAŞIM ONAYLARI
function renderPendingApprovals(data) {
  approvalsList.innerHTML = '';
  
  if (!data) {
    renderEmptyState(approvalsList, "check_circle_outline", "Bekleyen Onay Yok", "Onay bekleyen paylaşım talebi bulunmamaktadır.");
    return;
  }

  const items = [];
  if (Array.isArray(data)) {
    data.forEach((val, i) => {
      if (val && val.status === 'pending') items.push({ ...val, id: i.toString() });
    });
  } else {
    Object.keys(data).forEach(key => {
      if (data[key].status === 'pending') items.push({ ...data[key], id: key });
    });
  }

  if (items.length === 0) {
    renderEmptyState(approvalsList, "check_circle_outline", "Bekleyen Onay Yok", "Onay bekleyen paylaşım talebi bulunmamaktadır.");
    return;
  }

  items.sort((a, b) => b.timestamp - a.timestamp);

  items.forEach(item => {
    const card = document.createElement('div');
    card.className = 'approval-card';
    
    card.innerHTML = `
      <div class="approval-card-header">
        <div class="author-info">
          <div class="author-avatar">${item.author ? item.author.substring(0,1).toUpperCase() : 'A'}</div>
          <div class="author-details">
            <span class="author-name">${item.author || 'Belirsiz'}</span>
            <span class="author-title">Paylaşım Talebi</span>
          </div>
        </div>
        <span class="type-badge ${item.type || 'other'}">${item.type || 'Diğer'}</span>
      </div>
      <div class="approval-card-body">
        <h4 class="approval-title">${item.title || 'Başlıksız'}</h4>
        <p class="approval-desc">${item.description || ''}</p>
        <div class="approval-meta">
          ${item.date ? `<div class="meta-item"><span class="material-icons-round">calendar_today</span><span>${item.date}</span></div>` : ''}
          ${item.location ? `<div class="meta-item"><span class="material-icons-round">place</span><span>${item.location}</span></div>` : ''}
        </div>
      </div>
      <div class="approval-card-actions">
        <button class="btn-reject" onclick="handleApprovalAction('${item.id}', 'rejected', '${(item.title || 'Başlıksız').replace(/'/g, "\\'")}')">Reddet</button>
        <button class="btn-approve" onclick="handleApprovalAction('${item.id}', 'approved', '${(item.title || 'Başlıksız').replace(/'/g, "\\'")}')">Onayla</button>
      </div>
    `;
    approvalsList.appendChild(card);
  });
}

function handleApprovalAction(id, newStatus, title) {
  db.ref(`announcements/${id}/status`).set(newStatus)
    .then(() => {
      const actionText = newStatus === 'approved' ? 'onaylandı' : 'reddedildi';
      writeLog(currentUser.name, `"${title}" başlıklı paylaşım talebi ${actionText}.`, "Paylaşımlar");
      alert(`Paylaşım talebi başarıyla ${actionText}.`);
    })
    .catch(err => {
      alert("Hata oluştu: " + err.message);
    });
}

// RENDER TAB 2: CRM / ÇALIŞANLAR
function renderEmployees(list) {
  employeeGrid.innerHTML = '';
  
  if (list.length === 0) {
    renderEmptyState(employeeGrid, "people_outline", "Kayıtlı Çalışan Yok", "Sistemde listelenecek çalışan bulunmamaktadır.");
    return;
  }

  list.forEach(emp => {
    const card = document.createElement('div');
    card.className = 'employee-card';
    
    card.innerHTML = `
      <div class="emp-card-header">
        <div class="emp-avatar">${emp.name ? emp.name.substring(0,1).toUpperCase() : 'Ç'}</div>
        <div class="emp-main-info">
          <span class="emp-name">${emp.name || ''} ${emp.surname || ''}</span>
          <span class="emp-role">${emp.department || 'Birim Yok'} • ${emp.role || 'Rol Yok'}</span>
        </div>
        <button class="emp-btn-edit" onclick="openEditEmployeeModal('${emp.uid}')">
          <span class="material-icons-round">edit</span>
        </button>
      </div>
      <div class="emp-card-details">
        <div class="emp-detail-row">
          <span class="material-icons-round">badge</span>
          <span>Sicil Kodu: <b>${emp.employeeCode || '-'}</b></span>
        </div>
        <div class="emp-detail-row">
          <span class="material-icons-round">phone_callback</span>
          <span>Dahili Hat: <b>${emp.extension || '-'}</b></span>
        </div>
        <div class="emp-detail-row">
          <span class="material-icons-round">mail</span>
          <span>${emp.email || '-'}</span>
        </div>
        <div class="emp-detail-row">
          <span class="material-icons-round">phone</span>
          <span>${emp.phone || '-'}</span>
        </div>
      </div>
      <div class="emp-card-footer">
        <span>Yaş: ${emp.age || '-'}</span>
        <span>Kan: ${emp.bloodGroup ? emp.bloodGroup.toUpperCase() : '-'}</span>
      </div>
    `;
    employeeGrid.appendChild(card);
  });
}

function filterEmployees() {
  const query = employeeSearch.value.toLowerCase().trim();
  if (query === '') {
    renderEmployees(employeesCache);
  } else {
    const filtered = employeesCache.filter(emp => {
      const nameMatch = emp.name && emp.name.toLowerCase().includes(query);
      const surnameMatch = emp.surname && emp.surname.toLowerCase().includes(query);
      const deptMatch = emp.department && emp.department.toLowerCase().includes(query);
      const roleMatch = emp.role && emp.role.toLowerCase().includes(query);
      return nameMatch || surnameMatch || deptMatch || roleMatch;
    });
    renderEmployees(filtered);
  }
}

function openEditEmployeeModal(uid) {
  const emp = employeesCache.find(e => e.uid === uid);
  if (!emp) return;

  document.getElementById('emp-uid').value = emp.uid;
  document.getElementById('emp-name').value = emp.name || '';
  document.getElementById('emp-surname').value = emp.surname || '';
  document.getElementById('emp-email').value = emp.email || '';
  document.getElementById('emp-phone').value = emp.phone || '';
  document.getElementById('emp-age').value = emp.age || 30;
  document.getElementById('emp-blood').value = emp.bloodGroup || '';
  document.getElementById('emp-code').value = emp.employeeCode || '';
  document.getElementById('emp-ext').value = emp.extension || '';
  document.getElementById('emp-dept').value = emp.department || '';
  document.getElementById('emp-role').value = emp.role || 'İHH Çalışanı';

  empModalTitle.textContent = "Çalışan Bilgilerini Düzenle";
  btnSaveEmployee.textContent = "Güncelle";
  employeeModal.classList.add('active');
}

function saveEmployee() {
  const uid = document.getElementById('emp-uid').value;
  const name = document.getElementById('emp-name').value.trim();
  const surname = document.getElementById('emp-surname').value.trim();
  const email = document.getElementById('emp-email').value.trim();
  const phone = document.getElementById('emp-phone').value.trim();
  const age = parseInt(document.getElementById('emp-age').value);
  const blood = document.getElementById('emp-blood').value.trim();
  const code = document.getElementById('emp-code').value.trim();
  const ext = document.getElementById('emp-ext').value.trim();
  const dept = document.getElementById('emp-dept').value.trim();
  const role = document.getElementById('emp-role').value;

  const data = {
    name: name,
    surname: surname,
    email: email,
    phone: phone,
    age: age,
    bloodGroup: blood,
    employeeCode: code,
    extension: ext,
    department: dept,
    role: role,
    joinTimestamp: Date.now()
  };

  const isEdit = uid !== '';
  const ref = isEdit ? db.ref(`users/${uid}`) : db.ref('users').push();

  ref.set(data)
    .then(() => {
      const actionText = isEdit ? 'bilgileri güncellendi' : 'sisteme eklendi';
      writeLog(currentUser.name, `"${name} ${surname}" isimli çalışan ${actionText}.`, "CRM / Çalışanlar");
      employeeModal.classList.remove('active');
      alert(`Çalışan başarıyla ${isEdit ? 'güncellendi' : 'eklendi'}.`);
    })
    .catch(err => {
      alert("Hata oluştu: " + err.message);
    });
}

// RENDER TAB 3: BORDRO YÖNETİMİ
function renderPayrolls(data) {
  payrollsGrid.innerHTML = '';
  
  if (!data) {
    renderEmptyState(payrollsGrid, "receipt_long", "Bordro Bulunmuyor", "Sistemde yayınlanmış maaş bordrosu bulunmamaktadır.");
    return;
  }

  const items = [];
  if (Array.isArray(data)) {
    data.forEach((val, i) => {
      if (val) items.push({ ...val, id: i.toString() });
    });
  } else {
    Object.keys(data).forEach(key => {
      items.push({ ...data[key], id: key });
    });
  }

  if (items.length === 0) {
    renderEmptyState(payrollsGrid, "receipt_long", "Bordro Bulunmuyor", "Sistemde yayınlanmış maaş bordrosu bulunmamaktadır.");
    return;
  }

  // Render cards
  items.forEach(pay => {
    const totalPaid = (pay.netSalary || 0) + (pay.allowances || 0) - (pay.deductions || 0);
    const card = document.createElement('div');
    card.className = 'payroll-card';
    
    card.innerHTML = `
      <div class="pay-card-header">
        <span class="pay-emp-name">${pay.userName || 'Çalışan Bilinmiyor'}</span>
        <span class="pay-date-badge">${pay.month || ''} ${pay.year || ''}</span>
      </div>
      <div class="pay-details">
        <div class="pay-row">
          <span>Net Maaş</span>
          <span><b>${pay.netSalary ? pay.netSalary.toLocaleString() : '0'} TL</b></span>
        </div>
        <div class="pay-row">
          <span>Sosyal Yardım / Prim</span>
          <span><b>+${pay.allowances ? pay.allowances.toLocaleString() : '0'} TL</b></span>
        </div>
        <div class="pay-row">
          <span>Kesintiler</span>
          <span><b>-${pay.deductions ? pay.deductions.toLocaleString() : '0'} TL</b></span>
        </div>
        <div class="pay-row total">
          <span>Toplam Ödenen</span>
          <span><b>${totalPaid.toLocaleString()} TL</b></span>
        </div>
      </div>
    `;
    payrollsGrid.appendChild(card);
  });
}

function populateEmployeeDropdown() {
  payEmployeeSelect.innerHTML = '';
  
  if (employeesCache.length === 0) {
    const opt = document.createElement('option');
    opt.value = '';
    opt.textContent = 'Önce çalışan ekleyin';
    payEmployeeSelect.appendChild(opt);
    return;
  }

  employeesCache.forEach(emp => {
    const opt = document.createElement('option');
    opt.value = emp.uid;
    opt.dataset.fullname = `${emp.name} ${emp.surname}`;
    opt.textContent = `${emp.name} ${emp.surname} (${emp.department || ''})`;
    payEmployeeSelect.appendChild(opt);
  });
}

function savePayroll() {
  const empIdx = payEmployeeSelect.selectedIndex;
  if (empIdx === -1) return;

  const selectedOpt = payEmployeeSelect.options[empIdx];
  const userId = selectedOpt.value;
  const userName = selectedOpt.dataset.fullname;

  const month = document.getElementById('pay-month').value.trim();
  const year = parseInt(document.getElementById('pay-year').value);
  const netSalary = parseFloat(document.getElementById('pay-netsalary').value);
  const allowances = parseFloat(document.getElementById('pay-allowance').value);
  const deductions = parseFloat(document.getElementById('pay-deductions').value);

  const data = {
    userId: userId,
    userName: userName,
    month: month,
    year: year,
    netSalary: netSalary,
    allowances: allowances,
    deductions: deductions,
    timestamp: Date.now()
  };

  db.ref('payrolls').push(data)
    .then(() => {
      writeLog(currentUser.name, `"${userName}" için ${month} ${year} dönemine ait maaş bordrosu oluşturuldu.`, "Maaş Bordroları");
      payrollModal.classList.remove('active');
      alert("Bordro başarıyla oluşturuldu.");
    })
    .catch(err => {
      alert("Hata oluştu: " + err.message);
    });
}

// RENDER TAB 4: İZİN TALEPLERİ
function renderLeaveRequests(data) {
  leavesTableBody.innerHTML = '';
  
  if (!data) {
    leavesTableBody.innerHTML = `<tr><td colspan="7" class="table-loading">Kayıtlı izin talebi bulunmamaktadır.</td></tr>`;
    return;
  }

  const items = [];
  if (Array.isArray(data)) {
    data.forEach((val, i) => {
      if (val) items.push({ ...val, id: i.toString() });
    });
  } else {
    Object.keys(data).forEach(key => {
      items.push({ ...data[key], id: key });
    });
  }

  if (items.length === 0) {
    leavesTableBody.innerHTML = `<tr><td colspan="7" class="table-loading">Kayıtlı izin talebi bulunmamaktadır.</td></tr>`;
    return;
  }

  // Sort descending by timestamp
  items.sort((a, b) => b.timestamp - a.timestamp);

  items.forEach(req => {
    const tr = document.createElement('tr');
    
    // Status formatting
    let statusClass = 'pending';
    let statusText = 'Beklemede';
    if (req.status === 'approved') {
      statusClass = 'approved';
      statusText = 'Onaylandı';
    } else if (req.status === 'rejected') {
      statusClass = 'rejected';
      statusText = 'Reddedildi';
    }

    tr.innerHTML = `
      <td><b>${req.userName || 'Bilinmeyen Çalışan'}</b></td>
      <td>${req.department || 'Birim Yok'}</td>
      <td>${req.leaveType || 'İzin'}</td>
      <td>${req.startDate || ''} - ${req.endDate || ''}</td>
      <td>${req.durationDays || 0} Gün</td>
      <td><span class="status-badge ${statusClass}">${statusText}</span></td>
      <td class="row-actions">
        ${req.status === 'pending' ? `
          <button class="btn-table-action approve" title="Onayla" onclick="handleLeaveAction('${req.id}', 'approved', '${(req.userName || 'Çalışan').replace(/'/g, "\\'")}', '${req.leaveType}')">
            <span class="material-icons-round">check_circle</span>
          </button>
          <button class="btn-table-action reject" title="Reddet" onclick="handleLeaveAction('${req.id}', 'rejected', '${(req.userName || 'Çalışan').replace(/'/g, "\\'")}', '${req.leaveType}')">
            <span class="material-icons-round">cancel</span>
          </button>
        ` : '-'}
      </td>
    `;
    leavesTableBody.appendChild(tr);
  });
}

function handleLeaveAction(id, newStatus, userName, leaveType) {
  db.ref(`leaveRequests/${id}/status`).set(newStatus)
    .then(() => {
      const actionText = newStatus === 'approved' ? 'onaylandı' : 'reddedildi';
      writeLog(currentUser.name, `"${userName}" adlı çalışanın ${leaveType} talebi ${actionText}.`, "İzin Talepleri");
      alert(`İzin talebi başarıyla ${actionText}.`);
    })
    .catch(err => {
      alert("Hata oluştu: " + err.message);
    });
}

// RENDER TAB 5: SİSTEM LÖGLARI
function renderLogs(data) {
  logsTableBody.innerHTML = '';
  
  if (!data) {
    logsTableBody.innerHTML = `<tr><td colspan="4" class="table-loading">Kayıtlı sistem günlüğü bulunmamaktadır.</td></tr>`;
    return;
  }

  const items = [];
  if (Array.isArray(data)) {
    data.forEach((val, i) => {
      if (val) items.push({ ...val, id: i.toString() });
    });
  } else {
    Object.keys(data).forEach(key => {
      items.push({ ...data[key], id: key });
    });
  }

  if (items.length === 0) {
    logsTableBody.innerHTML = `<tr><td colspan="4" class="table-loading">Kayıtlı sistem günlüğü bulunmamaktadır.</td></tr>`;
    return;
  }

  // Sort descending by timestamp
  items.sort((a, b) => b.timestamp - a.timestamp);

  items.forEach(log => {
    const tr = document.createElement('tr');
    
    // Format timestamp
    const date = new Date(log.timestamp);
    const dateStr = `${date.toLocaleDateString('tr-TR')} ${date.toLocaleTimeString('tr-TR')}`;

    tr.innerHTML = `
      <td><span style="font-family: monospace; color: var(--text-secondary);">${dateStr}</span></td>
      <td><b>${log.user || 'Sistem'}</b></td>
      <td>${log.detail || ''}</td>
      <td><span class="type-badge other" style="font-size: 9px; padding: 2px 6px;">${log.department || 'Genel'}</span></td>
    `;
    logsTableBody.appendChild(tr);
  });
}

// ==================== LOGGING HELPER ====================
function writeLog(user, detail, department) {
  const logData = {
    timestamp: Date.now(),
    user: user,
    detail: detail,
    department: department
  };
  db.ref('logs').push(logData);
}

// ==================== OTHER HELPERS ====================
function renderEmptyState(container, icon, title, desc) {
  container.innerHTML = `
    <div class="empty-state" style="grid-column: 1 / -1; width: 100%;">
      <span class="material-icons-round">${icon}</span>
      <h3>${title}</h3>
      <p>${desc}</p>
    </div>
  `;
}

// RENDER TAB 6: DEĞERLENDİRMELER
function renderEvaluations(data) {
  const evaluationsList = document.getElementById('evaluations-list');
  if (!evaluationsList) return;
  evaluationsList.innerHTML = '';
  
  if (!data) {
    renderEmptyState(evaluationsList, "assignment_turned_in", "Değerlendirme Bulunmuyor", "Sistemde gönderilmiş yıl sonu değerlendirme raporu bulunmamaktadır.");
    return;
  }

  const items = [];
  if (Array.isArray(data)) {
    data.forEach((val, i) => {
      if (val) items.push({ ...val, id: i.toString() });
    });
  } else {
    Object.keys(data).forEach(key => {
      items.push({ ...data[key], id: key });
    });
  }

  if (items.length === 0) {
    renderEmptyState(evaluationsList, "assignment_turned_in", "Değerlendirme Bulunmuyor", "Sistemde gönderilmiş yıl sonu değerlendirme raporu bulunmamaktadır.");
    return;
  }

  // Sort by timestamp desc
  items.sort((a, b) => b.timestamp - a.timestamp);

  items.forEach(eval => {
    const card = document.createElement('div');
    card.className = 'approval-card';
    card.style.marginBottom = '20px';
    
    const avgScore = ((eval.performanceScore || 0) + (eval.leadershipScore || 0) + (eval.cooperationScore || 0)) / 3.0;

    card.innerHTML = `
      <div class="eval-card-header">
        <div class="eval-author-info">
          <div class="eval-author-avatar">${eval.subordinateName ? eval.subordinateName.substring(0,1).toUpperCase() : 'P'}</div>
          <div class="eval-author-details">
            <span class="eval-author-name">${eval.subordinateName || 'Çalışan'}</span>
            <span class="eval-author-title">Yönetici: ${eval.managerName || 'Yönetici'}</span>
          </div>
        </div>
        <span class="eval-badge">Ortalama: ${avgScore.toFixed(1)} / 5</span>
      </div>
      <div class="approval-card-body">
        <div class="eval-scores-container">
          <div class="eval-score-item">Performans: <b>${eval.performanceScore || 0} / 5</b></div>
          <div class="eval-score-item">Liderlik: <b>${eval.leadershipScore || 0} / 5</b></div>
          <div class="eval-score-item">Uyum: <b>${eval.cooperationScore || 0} / 5</b></div>
        </div>
        <h4 class="eval-section-title">Geri Bildirim / Değerlendirme Notu</h4>
        <p class="eval-desc">${eval.feedback || ''}</p>
      </div>
      <div class="eval-footer">
        <span>${eval.year || '2026'} Dönemi</span>
      </div>
    `;
    evaluationsList.appendChild(card);
  });
}
