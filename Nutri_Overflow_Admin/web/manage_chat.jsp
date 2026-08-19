<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Tư vấn Trực tiếp & Hỗ trợ Khách hàng - NutriOverflow</title>
        <jsp:include page="includes/header.jsp" />
        <style>
            .chat-container {
                height: calc(100vh - 180px);
                min-height: 550px;
            }
            .session-item {
                cursor: pointer;
                transition: background-color 0.2s ease;
                border-bottom: 1px solid #f1f5f9;
            }
            .session-item:hover {
                background-color: #f8fafc;
            }
            .session-item.active {
                background-color: #f1f5f9;
                border-left: 4px solid #8b0000;
            }
            .chat-history {
                height: 380px;
                overflow-y: auto;
                background-color: #f8fafc;
                border-radius: 12px;
                padding: 1rem;
                display: flex;
                flex-direction: column;
                gap: 0.75rem;
            }
            .msg-bubble {
                max-width: 75%;
                padding: 0.65rem 1rem;
                border-radius: 14px;
                font-size: 0.9rem;
                line-height: 1.45;
                word-wrap: break-word;
            }
            .msg-customer {
                align-self: flex-start;
                background-color: #ffffff;
                color: #1e293b;
                border: 1px solid #e2e8f0;
                border-bottom-left-radius: 2px;
            }
            .msg-ai {
                align-self: flex-start;
                background-color: #f1f5f9;
                color: #475569;
                border: 1px dashed #cbd5e1;
                border-bottom-left-radius: 2px;
            }
            .msg-staff {
                align-self: flex-end;
                background-color: #8b0000;
                color: #ffffff;
                border-bottom-right-radius: 2px;
                box-shadow: 0 2px 5px rgba(139, 0, 0, 0.2);
            }
            .msg-system {
                align-self: center;
                background-color: #f1f5f9;
                color: #64748b;
                font-size: 0.78rem;
                font-style: italic;
                padding: 0.35rem 0.75rem;
                border-radius: 30px;
                max-width: 90%;
                text-align: center;
            }
            .simulator-panel {
                background-color: #0f172a;
                color: #e2e8f0;
                border-radius: 16px;
                padding: 1.25rem;
                height: 100%;
                display: flex;
                flex-direction: column;
            }
            .simulator-history {
                height: 200px;
                overflow-y: auto;
                background-color: #1e293b;
                border-radius: 8px;
                padding: 0.75rem;
                font-size: 0.82rem;
                display: flex;
                flex-direction: column;
                gap: 0.5rem;
            }
            .sim-msg-me {
                align-self: flex-end;
                background-color: #0284c7;
                color: #ffffff;
                padding: 0.4rem 0.75rem;
                border-radius: 10px;
                border-bottom-right-radius: 2px;
                max-width: 80%;
            }
            .sim-msg-other {
                align-self: flex-start;
                background-color: #334155;
                color: #f1f5f9;
                padding: 0.4rem 0.75rem;
                border-radius: 10px;
                border-bottom-left-radius: 2px;
                max-width: 80%;
            }
            .admin-tab-container .nav-link {
                color: #4b5563 !important;
                background: transparent !important;
                padding: 0.6rem 1.5rem !important;
                border-radius: 8px !important;
                transition: all 0.2s ease !important;
                font-size: 0.9rem !important;
                text-transform: none !important;
                letter-spacing: normal !important;
                font-weight: 600 !important;
                white-space: nowrap !important;
            }
            .admin-tab-container .nav-link::after {
                display: none !important;
            }
            .admin-tab-container .nav-link.active {
                color: #ffffff !important;
                background-color: #8b0000 !important;
                box-shadow: 0 4px 12px rgba(139, 0, 0, 0.25) !important;
            }
            .admin-tab-container .nav-link:hover:not(.active) {
                color: #8b0000 !important;
                background-color: #f3f4f6 !important;
            }
            .admin-tab-container ul {
                scrollbar-width: none;
                -ms-overflow-style: none;
            }
            .admin-tab-container ul::-webkit-scrollbar {
                display: none;
            }
        </style>
    </head>
    <body class="bg-light">
        <c:set var="activeTab" value="Chat" scope="request" />
        <jsp:include page="includes/sidebar.jsp" />

        <!-- Main Navbar -->
        <nav class="navbar navbar-expand-lg navbar-dark mb-4 shadow-sm" style="background-color: #8b0000;">
            <div class="container-fluid px-4">
                <div class="d-flex align-items-center">
                    <button class="btn btn-outline-light me-3" type="button" data-bs-toggle="offcanvas" data-bs-target="#adminSidebar" aria-controls="adminSidebar">
                        <i class="fas fa-bars"></i>
                    </button>
                    <span class="navbar-brand mb-0 h1"><i class="fas fa-user-shield me-2"></i>Hệ thống Quản trị NutriOverflow</span>
                </div>
                <div class="d-flex align-items-center">
                    <span class="text-white me-3">Xin chào, <strong>${sessionScope.LOGIN_USER.fullName}</strong></span>
                    <a href="MainController?action=Logout" class="btn btn-outline-light btn-sm"><i class="fas fa-sign-out-alt"></i> Đăng xuất</a>
                </div>
            </div>
        </nav>

        <div class="container-fluid px-4 pb-5">
            <!-- Toast notification container -->
            <div class="toast-container position-fixed top-0 end-0 p-3" style="z-index: 1080;">
                <div id="liveChatToast" class="toast align-items-center text-white bg-danger border-0" role="alert" aria-live="assertive" aria-atomic="true">
                    <div class="d-flex">
                        <div class="toast-body">
                            <i class="fas fa-bell me-2"></i> <span id="toastMessage">Yêu cầu tư vấn trực tiếp mới!</span>
                        </div>
                        <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
                    </div>
                </div>
            </div>

            <div class="row g-3 chat-container">
                <!-- COLUMN 1: SESSIONS LIST (Width 3) -->
                <div class="col-md-3">
                    <div class="card border-0 shadow-sm rounded-4 h-100 d-flex flex-column">
                        <div class="p-3 border-bottom">
                            <h6 class="fw-bold text-dark mb-0"><i class="fas fa-comments me-2 text-danger"></i>Cuộc trò chuyện</h6>
                        </div>
                        
                        <!-- Tabs to filter sessions -->
                        <ul class="nav nav-tabs nav-fill bg-light" id="sessionTabs" role="tablist">
                            <li class="nav-item" role="presentation">
                                <button class="nav-link active py-2 border-0 small fw-bold" id="tab-waiting" data-filter="WAITING_STAFF" onclick="changeSessionTab('WAITING_STAFF')" type="button">Chờ (0)</button>
                            </li>
                            <li class="nav-item" role="presentation">
                                <button class="nav-link py-2 border-0 small fw-bold" id="tab-connected" data-filter="CONNECTED" onclick="changeSessionTab('CONNECTED')" type="button">Đang chat (0)</button>
                            </li>
                            <li class="nav-item" role="presentation">
                                <button class="nav-link py-2 border-0 small fw-bold" id="tab-closed" data-filter="CLOSED" onclick="changeSessionTab('CLOSED')" type="button">Lịch sử</button>
                            </li>
                        </ul>

                        <div class="flex-grow-1 overflow-y-auto" id="sessionsListContainer" style="max-height: 400px;">
                            <!-- Sessions will load dynamically via JS -->
                            <div class="text-center py-5 text-muted">
                                <i class="fas fa-circle-notch fa-spin fa-2x mb-3 text-muted"></i>
                                <p class="small">Đang tải cuộc trò chuyện...</p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- COLUMN 2: CHAT CONSOLE (Width 5) -->
                <div class="col-md-5">
                    <div class="card border-0 shadow-sm rounded-4 h-100 d-flex flex-column" id="chatConsoleCard">
                        <div class="text-center py-5 my-5 text-muted flex-grow-1 d-flex flex-column align-items-center justify-content-center" id="noSessionSelected">
                            <i class="fas fa-comment-medical fa-4x mb-3 text-danger opacity-50"></i>
                            <h5 class="fw-bold text-dark">Hỗ trợ & Tư vấn sản phẩm</h5>
                            <p class="small text-muted px-4">Vui lòng chọn một phiên trò chuyện từ danh sách bên trái để xem nội dung và kết nối trực tiếp với khách hàng.</p>
                        </div>

                        <!-- Chat Console (Hidden by default, shown when session selected) -->
                        <div class="d-none h-100 flex-column" id="activeChatConsole" style="display: flex;">
                            <!-- Header -->
                            <div class="p-3 border-bottom d-flex align-items-center justify-content-between bg-light rounded-top-4">
                                <div>
                                    <h6 class="fw-bold text-dark mb-1" id="activeCustomerName">Customer Name</h6>
                                    <span id="activeSessionStatus">Status Badge</span>
                                </div>
                                <div class="d-flex gap-2">
                                    <button class="btn btn-sm btn-success fw-bold d-none" id="btnConnect" onclick="connectToSession()"><i class="fas fa-link me-1"></i> Tiếp nhận</button>
                                    <button class="btn btn-sm btn-outline-warning fw-bold d-none" id="btnHandback" onclick="handbackToAISession()"><i class="fas fa-robot me-1"></i> Trả về AI</button>
                                    <button class="btn btn-sm btn-outline-danger fw-bold d-none" id="btnClose" onclick="closeSession()"><i class="fas fa-times-circle me-1"></i> Đóng phiên</button>
                                </div>
                            </div>

                            <!-- Chat Messages Body -->
                            <div class="chat-history flex-grow-1 p-3" id="chatHistoryContainer">
                                <!-- Messages will load dynamically -->
                            </div>

                            <!-- Input Bar -->
                            <div class="p-3 border-top bg-white rounded-bottom-4">
                                <div class="input-group">
                                    <input type="text" id="staffMessageInput" class="form-control" placeholder="Nhập tin nhắn tư vấn..." onkeydown="handleStaffKeydown(event)">
                                    <button class="btn btn-danger fw-bold" id="btnSendStaff" onclick="sendStaffMessage()"><i class="fas fa-paper-plane"></i> Gửi</button>
                                </div>
                                <div class="text-danger small mt-1 d-none" id="chatInputWarning">Chỉ có thể gửi tin nhắn khi đã Nhập cuộc (CONNECTED) với khách!</div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- COLUMN 3: CUSTOMER SIMULATOR (Width 4) -->
                <div class="col-md-4">
                    <div class="simulator-panel shadow-sm">
                        <div class="border-bottom border-secondary pb-2 mb-3">
                            <h6 class="fw-bold text-brand mb-1"><i class="fas fa-laptop-code me-2"></i>Bộ Giả lập Khách hàng (Testing)</h6>
                            <p class="small text-muted mb-0" style="font-size: 0.75rem;">Đóng vai khách hàng để tương tác và kiểm tra tính năng live chat / AI handoff.</p>
                        </div>

                        <!-- Setup Simulator Session -->
                        <div id="simSetupArea" class="my-auto text-center py-4">
                            <i class="fas fa-user-circle fa-3x text-info mb-3"></i>
                            <div class="mb-3">
                                <label class="form-label small fw-bold text-secondary">Tên khách hàng kiểm thử</label>
                                <input type="text" id="simCustomerName" class="form-control bg-dark text-white border-secondary text-center" value="Khách hàng Demo">
                            </div>
                            <button class="btn btn-info w-100 fw-bold" onclick="createSimulatedSession()"><i class="fas fa-plus me-1"></i> Bắt đầu giả lập</button>
                        </div>

                        <!-- Active Simulator (Hidden initially) -->
                        <div id="simActiveArea" class="d-none h-100 d-flex flex-column" style="display: flex;">
                            <div class="d-flex align-items-center justify-content-between mb-2">
                                <span class="badge bg-info" id="simDisplayCustomerName">Khách hàng Demo</span>
                                <button class="btn btn-xs btn-outline-light py-0 px-2" style="font-size: 0.7rem;" onclick="resetSimulator()"><i class="fas fa-redo me-1"></i> Chọn tên khác</button>
                            </div>

                            <!-- Customer View Chat History -->
                            <div class="simulator-history flex-grow-1 mb-3" id="simHistoryContainer">
                                <!-- Messages -->
                            </div>

                            <!-- Simulator Quick Actions -->
                            <div class="mb-3 d-flex flex-column gap-2">
                                <label class="small text-secondary fw-bold mb-0">Hành động nhanh cho Khách hàng:</label>
                                <div class="d-flex flex-wrap gap-2">
                                    <button class="btn btn-xs btn-secondary py-1 px-2 text-white" style="font-size: 0.74rem;" onclick="simulateQuickAsk('Whey')"><i class="fas fa-shopping-cart me-1"></i> Hỏi Whey</button>
                                    <button class="btn btn-xs btn-secondary py-1 px-2 text-white" style="font-size: 0.74rem;" onclick="simulateQuickAsk('Bệnh lý')"><i class="fas fa-notes-medical me-1"></i> Câu hỏi bệnh lý (AI Handoff)</button>
                                    <button class="btn btn-xs btn-warning py-1 px-2 text-dark fw-bold" style="font-size: 0.74rem;" onclick="simulateManualHandoff()"><i class="fas fa-user-tie me-1"></i> Gọi nhân viên</button>
                                </div>
                            </div>

                            <!-- Customer Message Input -->
                            <div class="input-group">
                                <input type="text" id="simMessageInput" class="form-control bg-dark text-white border-secondary" placeholder="Tin nhắn của Khách..." onkeydown="handleCustomerKeydown(event)">
                                <button class="btn btn-info" onclick="sendCustomerMessage()"><i class="fas fa-paper-plane"></i> Gửi</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            // State variables
            let activeTab = 'WAITING_STAFF'; // WAITING_STAFF, CONNECTED, CLOSED
            let activeSessionId = null;
            let activeSession = null;
            let simSessionId = null;
            let simCustomerName = '';
            
            // Audio context for alerts
            let audioCtx = null;
            let knownWaitingSessions = new Set();
            let isFirstLoad = true;

            document.addEventListener("DOMContentLoaded", function() {
                // Initial fetch
                fetchSessions();
                
                // Set interval to poll for updates every 2 seconds
                setInterval(function() {
                    fetchSessions();
                    if (activeSessionId) {
                        fetchMessages(activeSessionId);
                    }
                    if (simSessionId) {
                        fetchSimMessages();
                    }
                }, 2000);
            });

            // Plays a dual-frequency beeping sound using HTML5 Web Audio API
            function playNotificationSound() {
                try {
                    if (!audioCtx) {
                        audioCtx = new (window.AudioContext || window.webkitAudioContext)();
                    }
                    
                    let osc1 = audioCtx.createOscillator();
                    let osc2 = audioCtx.createOscillator();
                    let gainNode = audioCtx.createGain();

                    osc1.type = 'sine';
                    osc1.frequency.setValueAtTime(523.25, audioCtx.currentTime); // C5
                    osc1.frequency.setValueAtTime(659.25, audioCtx.currentTime + 0.15); // E5

                    osc2.type = 'sine';
                    osc2.frequency.setValueAtTime(523.25 * 1.5, audioCtx.currentTime); 
                    osc2.frequency.setValueAtTime(659.25 * 1.5, audioCtx.currentTime + 0.15); 

                    gainNode.gain.setValueAtTime(0.15, audioCtx.currentTime);
                    gainNode.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.4);

                    osc1.connect(gainNode);
                    osc2.connect(gainNode);
                    gainNode.connect(audioCtx.destination);

                    osc1.start();
                    osc2.start();
                    osc1.stop(audioCtx.currentTime + 0.45);
                    osc2.stop(audioCtx.currentTime + 0.45);
                } catch(e) {
                    console.log("Audio not allowed or supported yet: " + e);
                }
            }

            function changeSessionTab(tabName) {
                activeTab = tabName;
                document.querySelectorAll('#sessionTabs button').forEach(btn => {
                    btn.classList.remove('active');
                });
                const activeBtn = document.querySelector('#sessionTabs button[data-filter="' + tabName + '"]');
                if (activeBtn) activeBtn.classList.add('active');
                
                fetchSessions();
            }

            // AJAX: Fetch sessions
            function fetchSessions() {
                const url = 'MainController?action=ChatAjax&subAction=getSessions&statusFilter=' + activeTab;
                
                fetch(url)
                    .then(response => response.json())
                    .then(data => {
                        if (data.success) {
                            renderSessions(data.sessions);
                            updateTabCounts();
                        }
                    })
                    .catch(err => console.error("Error fetching sessions:", err));
            }

            // Helper to update counters
            function updateTabCounts() {
                // Fetch all open sessions to calculate counts
                fetch('MainController?action=ChatAjax&subAction=getSessions&statusFilter=all')
                    .then(response => response.json())
                    .then(data => {
                        if (data.success) {
                            let waitingCount = 0;
                            let connectedCount = 0;
                            let newWaitingSession = false;

                            data.sessions.forEach(s => {
                                if (s.status === 'WAITING_STAFF') {
                                    waitingCount++;
                                    // Play sound if a new waiting session is discovered
                                    if (!knownWaitingSessions.has(s.sessionId)) {
                                        knownWaitingSessions.add(s.sessionId);
                                        newWaitingSession = true;
                                    }
                                } else if (s.status === 'CONNECTED') {
                                    connectedCount++;
                                }
                            });

                            document.getElementById('tab-waiting').innerText = 'Chờ (' + waitingCount + ')';
                            document.getElementById('tab-connected').innerText = 'Đang chat (' + connectedCount + ')';

                            if (newWaitingSession && !isFirstLoad) {
                                playNotificationSound();
                                showToast("Có yêu cầu tư vấn y tế/chuyển giao mới cần hỗ trợ!");
                            }
                            isFirstLoad = false;
                        }
                    });
            }

            function showToast(msg) {
                document.getElementById('toastMessage').innerText = msg;
                const toastEl = document.getElementById('liveChatToast');
                const toast = new bootstrap.Toast(toastEl);
                toast.show();
            }

            function renderSessions(sessions) {
                const container = document.getElementById('sessionsListContainer');
                if (sessions.length === 0) {
                    container.innerHTML = `<div class="text-center py-5 text-muted small"><i class="fas fa-folder-open fa-2x mb-2 opacity-50"></i><p>Không có cuộc trò chuyện nào</p></div>`;
                    return;
                }

                let html = '';
                sessions.forEach(s => {
                    const isActive = s.sessionId === activeSessionId ? 'active' : '';
                    let statusBadge = '';
                    if (s.status === 'WAITING_STAFF') {
                        statusBadge = '<span class="badge bg-warning text-dark float-end">Chờ CSKH</span>';
                    } else if (s.status === 'CONNECTED') {
                        statusBadge = '<span class="badge bg-primary float-end">CSKH Trực tiếp</span>';
                    } else if (s.status === 'ACTIVE') {
                        statusBadge = '<span class="badge bg-secondary float-end">AI Bot</span>';
                    }

                    // Format timestamp
                    const date = new Date(s.lastMessageAt);
                    const timeStr = date.getHours().toString().padStart(2, '0') + ':' + date.getMinutes().toString().padStart(2, '0');

                    html += ' <div class="session-item p-3 ' + isActive + '" onclick="selectSession(' + s.sessionId + ', \'' + s.customerName.replace(/'/g, "\\'") + '\', \'' + s.status + '\')">'
                        + ' <div class="d-flex justify-content-between align-items-center mb-1">'
                        + ' <span class="fw-bold text-dark text-truncate" style="max-width: 60%;">' + s.customerName + '</span>'
                        + ' <span class="text-muted small">' + timeStr + '</span>'
                        + ' </div>'
                        + ' <div class="text-truncate small text-secondary" style="max-width: 70%;">' + (s.lastMessageText || 'Chưa có tin nhắn') + '</div>'
                        + ' <div class="mt-1">' + statusBadge + '</div>'
                        + ' </div>';
                });
                container.innerHTML = html;
            }

            function selectSession(sessionId, customerName, status) {
                activeSessionId = sessionId;
                
                // Highlight
                document.querySelectorAll('.session-item').forEach(el => el.classList.remove('active'));
                
                // Show active chat console
                document.getElementById('noSessionSelected').classList.add('d-none');
                document.getElementById('activeChatConsole').classList.remove('d-none');

                document.getElementById('activeCustomerName').innerText = customerName;
                
                // Render status and adjust header buttons
                updateActiveSessionHeader(status);
                
                // Load messages
                fetchMessages(sessionId);
            }

            function updateActiveSessionHeader(status) {
                const badgeEl = document.getElementById('activeSessionStatus');
                const btnConnect = document.getElementById('btnConnect');
                const btnHandback = document.getElementById('btnHandback');
                const btnClose = document.getElementById('btnClose');
                const inputWarning = document.getElementById('chatInputWarning');
                const textInput = document.getElementById('staffMessageInput');

                btnConnect.classList.add('d-none');
                btnHandback.classList.add('d-none');
                btnClose.classList.add('d-none');
                inputWarning.classList.add('d-none');
                textInput.disabled = false;

                if (status === 'PENDING' || status === 'WAITING_STAFF') {
                    badgeEl.innerHTML = '<span class="badge bg-warning text-dark"><i class="fas fa-clock me-1"></i>Đang chờ tiếp nhận</span>';
                    btnConnect.classList.remove('d-none');
                    btnClose.classList.remove('d-none');
                    textInput.disabled = true;
                    inputWarning.classList.remove('d-none');
                } else if (status === 'CONNECTED') {
                    badgeEl.innerHTML = '<span class="badge bg-primary"><i class="fas fa-user-tie me-1"></i>Đang trò chuyện trực tiếp</span>';
                    btnHandback.classList.remove('d-none');
                    btnClose.classList.remove('d-none');
                } else if (status === 'ACTIVE') {
                    badgeEl.innerHTML = '<span class="badge bg-secondary"><i class="fas fa-robot me-1"></i>AI Đang phục vụ</span>';
                    btnConnect.classList.remove('d-none');
                    textInput.disabled = true;
                    inputWarning.classList.remove('d-none');
                } else {
                    badgeEl.innerHTML = '<span class="badge bg-dark"><i class="fas fa-check-circle me-1"></i>Đã đóng</span>';
                    textInput.disabled = true;
                }
            }

            // AJAX: Fetch messages
            function fetchMessages(sessionId) {
                const url = 'MainController?action=ChatAjax&subAction=getMessages&sessionId=' + sessionId;
                
                fetch(url)
                    .then(response => response.json())
                    .then(data => {
                        if (data.success) {
                            renderMessages(data.messages);
                            // Also sync status header in case of updates
                            // Find session in lists to check status
                            fetch('MainController?action=ChatAjax&subAction=getSessions&statusFilter=all')
                                .then(res => res.json())
                                .then(sessData => {
                                    if (sessData.success) {
                                        const sess = sessData.sessions.find(s => s.sessionId === sessionId);
                                        if (sess) {
                                            updateActiveSessionHeader(sess.status);
                                        }
                                    }
                                });
                        }
                    });
            }

            function renderMessages(messages) {
                const container = document.getElementById('chatHistoryContainer');
                let html = '';
                
                messages.forEach(m => {
                    let bubbleClass = '';
                    let senderLabel = '';
                    
                    if (m.senderType === 'STAFF') {
                        bubbleClass = 'msg-staff';
                        senderLabel = '<small class="d-block text-end text-white-50" style="font-size:0.7rem;">' + m.senderName + '</small>';
                    } else if (m.senderType === 'AI') {
                        bubbleClass = 'msg-ai';
                        senderLabel = '<small class="d-block text-secondary" style="font-size:0.7rem;"><i class="fas fa-robot text-danger me-1"></i>NutriBot AI</small>';
                    } else {
                        bubbleClass = 'msg-customer';
                        senderLabel = '<small class="d-block text-muted" style="font-size:0.7rem;">' + m.senderName + '</small>';
                    }

                    // Check if it is system message
                    if (m.messageText.startsWith('[Hệ thống]')) {
                        html += '<div class="msg-system">' + m.messageText + '</div>';
                    } else {
                        html += ' <div class="d-flex flex-column ' + (m.senderType === 'STAFF' ? 'align-items-end' : 'align-items-start') + '">'
                            + senderLabel
                            + ' <div class="msg-bubble ' + bubbleClass + ' mt-1">' + m.messageText + '</div>'
                            + ' </div>';
                    }
                });
                
                const oldScrollHeight = container.scrollHeight;
                container.innerHTML = html;
                
                // Scroll to bottom
                container.scrollTop = container.scrollHeight;
            }

            // Action: Connect
            function connectToSession() {
                if (!activeSessionId) return;
                
                fetch('MainController?action=ChatAjax&subAction=connect&sessionId=' + activeSessionId)
                    .then(response => response.json())
                    .then(data => {
                        if (data.success) {
                            showToast("Tiếp nhận phiên chat thành công!");
                            fetchSessions();
                            fetchMessages(activeSessionId);
                        }
                    });
            }

            // Action: Handback
            function handbackToAISession() {
                if (!activeSessionId) return;
                
                fetch('MainController?action=ChatAjax&subAction=handback&sessionId=' + activeSessionId)
                    .then(response => response.json())
                    .then(data => {
                        if (data.success) {
                            showToast("Đã chuyển giao lại cuộc trò chuyện cho AI!");
                            fetchSessions();
                            fetchMessages(activeSessionId);
                        }
                    });
            }

            // Action: Close
            function closeSession() {
                if (!activeSessionId) return;
                if (!confirm("Bạn có chắc muốn đóng cuộc trò chuyện này?")) return;

                fetch('MainController?action=ChatAjax&subAction=close&sessionId=' + activeSessionId)
                    .then(response => response.json())
                    .then(data => {
                        if (data.success) {
                            showToast("Đóng cuộc trò chuyện thành công!");
                            activeSessionId = null;
                            document.getElementById('noSessionSelected').classList.remove('d-none');
                            document.getElementById('activeChatConsole').classList.add('d-none');
                            fetchSessions();
                        }
                    });
            }

            // Action: Send staff message
            function sendStaffMessage() {
                const input = document.getElementById('staffMessageInput');
                const text = input.value.trim();
                if (!text || !activeSessionId) return;

                fetch('MainController?action=ChatAjax&subAction=sendStaffMessage&sessionId=' + activeSessionId + '&messageText=' + encodeURIComponent(text))
                    .then(response => response.json())
                    .then(data => {
                        if (data.success) {
                            input.value = '';
                            fetchMessages(activeSessionId);
                        }
                    });
            }

            function handleStaffKeydown(event) {
                if (event.key === "Enter") {
                    sendStaffMessage();
                }
            }


            /* ============================================================
               CUSTOMER SIMULATOR LOGIC
               ============================================================ */

            function createSimulatedSession() {
                const nameInput = document.getElementById('simCustomerName');
                const name = nameInput.value.trim();
                if (!name) return;

                fetch('MainController?action=ChatAjax&subAction=createCustomerSession&customerName=' + encodeURIComponent(name))
                    .then(response => response.json())
                    .then(data => {
                        if (data.success) {
                            simSessionId = data.sessionId;
                            simCustomerName = data.customerName;

                            document.getElementById('simSetupArea').classList.add('d-none');
                            document.getElementById('simActiveArea').classList.remove('d-none');
                            document.getElementById('simDisplayCustomerName').innerText = simCustomerName;
                            
                            // Initialize AudioContext if user clicks start
                            if (!audioCtx) {
                                audioCtx = new (window.AudioContext || window.webkitAudioContext)();
                            }

                            fetchSessions();
                            fetchSimMessages();
                        }
                    });
            }

            function resetSimulator() {
                simSessionId = null;
                simCustomerName = '';
                document.getElementById('simSetupArea').classList.remove('d-none');
                document.getElementById('simActiveArea').classList.add('d-none');
                document.getElementById('simHistoryContainer').innerHTML = '';
            }

            function fetchSimMessages() {
                if (!simSessionId) return;
                const url = 'MainController?action=ChatAjax&subAction=getMessages&sessionId=' + simSessionId;
                
                fetch(url)
                    .then(response => response.json())
                    .then(data => {
                        if (data.success) {
                            renderSimMessages(data.messages);
                        }
                    });
            }

            function renderSimMessages(messages) {
                const container = document.getElementById('simHistoryContainer');
                let html = '';

                messages.forEach(m => {
                    if (m.messageText.startsWith('[Hệ thống]')) {
                        html += '<div class="msg-system" style="font-size:0.75rem;">' + m.messageText + '</div>';
                    } else if (m.senderType === 'CUSTOMER') {
                        html += '<div class="sim-msg-me">' + m.messageText + '</div>';
                    } else {
                        // AI or STAFF
                        let sender = m.senderType === 'AI' ? 'AI Bot' : m.senderName;
                        html += ' <div class="sim-msg-other">'
                            + ' <small class="d-block text-secondary" style="font-size:0.68rem; margin-bottom: 2px;">' + sender + '</small>'
                            + m.messageText
                            + ' </div>';
                    }
                });

                container.innerHTML = html;
                container.scrollTop = container.scrollHeight;
            }

            function sendCustomerMessage() {
                const input = document.getElementById('simMessageInput');
                const text = input.value.trim();
                if (!text || !simSessionId) return;

                input.value = '';

                fetch('MainController?action=ChatAjax&subAction=sendCustomerMessage&sessionId=' + simSessionId + 
                      '&messageText=' + encodeURIComponent(text) + '&customerName=' + encodeURIComponent(simCustomerName))
                    .then(response => response.json())
                    .then(data => {
                        if (data.success) {
                            fetchSimMessages();
                            fetchSessions();
                            if (activeSessionId === simSessionId) {
                                fetchMessages(activeSessionId);
                            }
                        }
                    });
            }

            function handleCustomerKeydown(event) {
                if (event.key === "Enter") {
                    sendCustomerMessage();
                }
            }

            function simulateQuickAsk(type) {
                const input = document.getElementById('simMessageInput');
                if (type === 'Whey') {
                    input.value = "Shop có bán Whey Gold Standard không? Giá bao nhiêu thế?";
                } else if (type === 'Bệnh lý') {
                    input.value = "Tôi bị suy thận độ 2, có uống Whey Gold được không? Cách dùng chuyên sâu và chống chỉ định?";
                }
                sendCustomerMessage();
            }

            function simulateManualHandoff() {
                if (!simSessionId) return;
                
                fetch('MainController?action=ChatAjax&subAction=triggerManualHandoff&sessionId=' + simSessionId + '&customerName=' + encodeURIComponent(simCustomerName))
                    .then(response => response.json())
                    .then(data => {
                        if (data.success) {
                            fetchSimMessages();
                            fetchSessions();
                            if (activeSessionId === simSessionId) {
                                fetchMessages(activeSessionId);
                            }
                        }
                    });
            }
        </script>
    </body>
</html>
