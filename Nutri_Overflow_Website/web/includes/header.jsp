<%@page contentType="text/html" pageEncoding="UTF-8"%>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&family=Outfit:wght@600;700;800;900&display=swap" rel="stylesheet">
<style>
    /* =============================================
       NUTRIOVERFLOW — GLOBAL DESIGN SYSTEM v2
       Theme: Dark Obsidian + Electric Green
    ============================================= */
    :root {
        --brand:        #00e676;
        --brand-dark:   #00c853;
        --brand-deep:   #009624;
        --brand-glow:   rgba(0, 230, 118, 0.35);
        --brand-subtle: rgba(0, 230, 118, 0.08);
        --obsidian:     #080b12;
        --obsidian-2:   #0d1117;
        --obsidian-3:   #161b27;
        --glass-bg:     rgba(13, 17, 23, 0.92);
        --glass-border: rgba(0, 230, 118, 0.18);
        --bg-page:      #f0f2f5;
        --bg-card:      #ffffff;
        --txt:          #111827;
        --txt-muted:    #6b7280;
        --border:       #e5e7eb;
        --white-80:     rgba(255,255,255,0.80);
        --white-55:     rgba(255,255,255,0.55);
        --white-12:     rgba(255,255,255,0.12);
        --white-06:     rgba(255,255,255,0.06);
        --shadow-sm:    0 1px 4px rgba(0,0,0,0.07);
        --shadow-md:    0 4px 18px rgba(0,0,0,0.10);
        --shadow-lg:    0 12px 40px rgba(0,0,0,0.15);
        --shadow-brand: 0 0 24px rgba(0,230,118,0.30);
        --r-sm: 8px; --r-md: 14px; --r-lg: 20px; --r-xl: 50px;
        --ease: all 0.25s cubic-bezier(0.4,0,0.2,1);
        --spring: all 0.35s cubic-bezier(0.34,1.56,0.64,1);
    }
    *, *::before, *::after { box-sizing: border-box; }

    html { scroll-behavior: smooth; }

    body {
        font-family: 'Inter', sans-serif;
        background: var(--bg-page);
        color: var(--txt);
        font-size: 0.92rem;
        line-height: 1.65;
        opacity: 0;
        animation: bodyFadeIn 0.55s cubic-bezier(0.16, 1, 0.3, 1) forwards;
    }
    @keyframes bodyFadeIn { to { opacity: 1; } }

    /* ── BRAND COLOR ── */
    .text-brand { color: var(--brand) !important; }

    /* ══════════════════════════════════════════════
       NAVBAR — Premium Redesign
    ══════════════════════════════════════════════ */
    .navbar-custom {
        background: #080810 !important;
        backdrop-filter: blur(20px) saturate(180%);
        -webkit-backdrop-filter: blur(20px) saturate(180%);
        border-bottom: 1px solid var(--glass-border);
        padding: 0;
        min-height: 68px;
        position: sticky;
        top: 0;
        z-index: 1030;
        box-shadow: 0 4px 32px rgba(0,0,0,0.45), 0 1px 0 rgba(0,230,118,0.12);
        transition: box-shadow 0.3s ease;
    }
    .navbar-custom.scrolled {
        background: #080810 !important;
        box-shadow: 0 8px 40px rgba(0,0,0,0.6), 0 1px 0 rgba(0,230,118,0.20);
    }

    /* ── Brand Logo ── */
    .navbar-brand-logo {
        text-decoration: none;
        display: flex;
        align-items: center;
        gap: 10px;
        flex-shrink: 0;
        transition: var(--ease);
    }
    .navbar-brand-logo:hover .brand-logo-wrap {
        box-shadow: 0 0 0 2.5px var(--brand), var(--shadow-brand);
        transform: scale(1.05) rotate(-4deg);
    }
    .navbar-brand-logo:hover .brand-name-text { letter-spacing: 2.8px; }

    .brand-logo-wrap {
        width: 42px; height: 42px;
        border-radius: 50%;
        overflow: hidden;
        border: 2px solid rgba(0,230,118,0.55);
        box-shadow: 0 0 12px rgba(0,230,118,0.22), inset 0 0 6px rgba(0,0,0,0.2);
        flex-shrink: 0;
        transition: var(--spring);
    }
    .brand-logo-img {
        width: 100%; height: 100%;
        object-fit: cover;
        object-position: center;
        transform: scale(1.25);
        display: block;
    }
    .brand-name-text {
        font-family: 'Outfit', sans-serif;
        font-size: 1.15rem;
        font-weight: 800;
        letter-spacing: 2px;
        text-transform: uppercase;
        color: #ffffff;
        transition: letter-spacing 0.3s ease;
        line-height: 1;
    }
    .brand-name-accent { color: var(--brand); }

    /* ── Nav Links ── */
    .nav-link {
        font-family: 'Inter', sans-serif;
        font-weight: 600;
        font-size: 0.78rem;
        letter-spacing: 0.9px;
        text-transform: uppercase;
        color: var(--white-80) !important;
        padding: 0.4rem 0 !important;
        position: relative;
        transition: color 0.22s ease;
        white-space: nowrap;
    }
    .nav-link::after {
        content: '';
        position: absolute;
        bottom: -2px; left: 50%;
        transform: translateX(-50%);
        width: 0; height: 2px;
        background: linear-gradient(90deg, transparent, var(--brand), transparent);
        border-radius: 2px;
        transition: width 0.3s cubic-bezier(0.34,1.56,0.64,1);
    }
    .nav-link:hover { color: #fff !important; }
    .nav-link:hover::after { width: 100%; }

    /* ── Search ── */
    .search-wrap { position: relative; flex: 1; min-width: 0; }
    .search-inner {
        display: flex;
        align-items: center;
        background: rgba(255,255,255,0.05);
        border: 1.5px solid rgba(255,255,255,0.10);
        border-radius: var(--r-xl);
        padding: 5px 5px 5px 18px;
        transition: all 0.3s cubic-bezier(0.4,0,0.2,1);
        width: 100%;
        position: relative;
    }
    .search-inner::before {
        content: '';
        position: absolute;
        inset: -1px;
        border-radius: var(--r-xl);
        background: linear-gradient(135deg, rgba(0,230,118,0) 0%, rgba(0,230,118,0) 100%);
        opacity: 0;
        transition: opacity 0.3s ease;
        pointer-events: none;
    }
    .search-inner:focus-within {
        border-color: var(--brand);
        background: rgba(0,0,0,0.40);
        box-shadow: 0 0 0 3px rgba(0,230,118,0.15), 0 0 30px rgba(0,230,118,0.12), 0 4px 20px rgba(0,0,0,0.3);
    }
    .search-inner:focus-within::before { opacity: 1; }
    .search-icon-prefix {
        color: var(--white-55);
        font-size: 0.78rem;
        margin-right: 8px;
        flex-shrink: 0;
        transition: color 0.25s ease;
    }
    .search-inner:focus-within .search-icon-prefix { color: var(--brand); }
    .search-input {
        background: transparent !important;
        border: none !important;
        box-shadow: none !important;
        color: #fff !important;
        font-size: 0.85rem;
        padding: 0 !important;
        width: 100%;
        outline: none !important;
        letter-spacing: 0.2px;
    }
    .search-input::placeholder { color: rgba(255,255,255,0.38) !important; opacity: 1; }
    .search-btn {
        background: linear-gradient(135deg, var(--brand) 0%, var(--brand-dark) 100%);
        border: none;
        border-radius: var(--r-xl);
        color: #0a0a0a;
        font-weight: 800;
        width: 38px; height: 38px;
        display: flex; align-items: center; justify-content: center;
        flex-shrink: 0;
        transition: var(--spring);
        font-size: 0.8rem;
        box-shadow: 0 2px 10px rgba(0,230,118,0.35);
    }
    .search-btn:hover {
        background: linear-gradient(135deg, #2bff8e 0%, var(--brand) 100%);
        transform: scale(1.12) rotate(8deg);
        box-shadow: 0 0 20px rgba(0,230,118,0.65);
    }

    /* ── Cart Button Special ── */
    .nav-icon-btn-cart {
        display: inline-flex;
        align-items: center;
        gap: 7px;
        background: linear-gradient(135deg, rgba(0,230,118,0.14) 0%, rgba(0,200,83,0.08) 100%);
        border: 1.5px solid rgba(0,230,118,0.30);
        border-radius: var(--r-xl);
        color: rgba(0,230,118,0.90) !important;
        font-size: 0.82rem;
        font-weight: 700;
        padding: 0.42rem 1.1rem;
        text-decoration: none;
        transition: var(--ease);
        white-space: nowrap;
        letter-spacing: 0.3px;
        position: relative;
        box-shadow: 0 0 14px rgba(0,230,118,0.10);
    }
    .nav-icon-btn-cart:hover {
        background: linear-gradient(135deg, rgba(0,230,118,0.28) 0%, rgba(0,200,83,0.18) 100%);
        border-color: var(--brand);
        color: #fff !important;
        box-shadow: 0 0 24px rgba(0,230,118,0.35), 0 4px 16px rgba(0,0,0,0.25);
        transform: translateY(-2px);
    }
    .nav-icon-btn-cart .cart-icon-wrap {
        width: 22px; height: 22px;
        background: rgba(0,230,118,0.15);
        border-radius: 50%;
        display: flex; align-items: center; justify-content: center;
        font-size: 0.72rem;
        flex-shrink: 0;
        transition: transform 0.3s ease;
    }
    .nav-icon-btn-cart:hover .cart-icon-wrap { transform: scale(1.15) rotate(-8deg); }

    /* Search Dropdown */
    #searchResult, #searchResultMobile {
        position: absolute;
        z-index: 1055;
        width: 100%;
        min-width: 300px;
        top: calc(100% + 10px);
        background: rgba(13,17,23,0.97);
        backdrop-filter: blur(16px);
        border-radius: 18px;
        box-shadow: 0 20px 60px rgba(0,0,0,0.5), 0 0 0 1px rgba(0,230,118,0.12);
        border: 1px solid rgba(0,230,118,0.10);
        max-height: 380px;
        overflow-y: auto;
        overflow-x: hidden;
        animation: searchFadeIn 0.22s cubic-bezier(0.16, 1, 0.3, 1) both;
    }
    @keyframes searchFadeIn {
        from { opacity: 0; transform: translateY(-8px) scale(0.97); }
        to   { opacity: 1; transform: translateY(0)    scale(1); }
    }
    #searchResult::-webkit-scrollbar, #searchResultMobile::-webkit-scrollbar { width: 4px; }
    #searchResult::-webkit-scrollbar-track, #searchResultMobile::-webkit-scrollbar-track { background: transparent; }
    #searchResult::-webkit-scrollbar-thumb, #searchResultMobile::-webkit-scrollbar-thumb {
        background: rgba(0,230,118,0.2); border-radius: 10px;
    }
    #searchResult .list-group-item, #searchResultMobile .list-group-item,
    #searchResult a.list-group-item-action, #searchResultMobile a.list-group-item-action {
        padding: 10px 14px;
        transition: all 0.2s ease;
        background: transparent !important;
        border: none !important;
        border-bottom: 1px solid rgba(255,255,255,0.04) !important;
        display: flex !important;
        align-items: center !important;
        color: #ffffff !important;
        text-decoration: none !important;
    }
    #searchResult .list-group-item:last-child, #searchResultMobile .list-group-item:last-child {
        border-bottom: none !important;
    }
    #searchResult .list-group-item:hover, #searchResultMobile .list-group-item:hover,
    #searchResult a.list-group-item-action:hover, #searchResultMobile a.list-group-item-action:hover {
        background: rgba(0,230,118,0.08) !important;
        color: #ffffff !important;
        padding-left: 18px;
    }
    #searchResult .list-group-item div, #searchResultMobile .list-group-item div,
    #searchResult a.list-group-item-action div, #searchResultMobile a.list-group-item-action div {
        color: inherit;
    }
    #searchResult .list-group-item img, #searchResultMobile .list-group-item img {
        border-radius: 8px;
        transition: transform 0.22s ease;
    }
    #searchResult .list-group-item:hover img, #searchResultMobile .list-group-item:hover img {
        transform: scale(1.06);
    }

    /* ── Icon Buttons ── */
    .nav-icon-btn {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        background: var(--white-06);
        border: 1px solid var(--white-12);
        border-radius: var(--r-xl);
        color: var(--white-80) !important;
        font-size: 0.79rem;
        font-weight: 600;
        padding: 0.38rem 1rem;
        text-decoration: none;
        transition: var(--ease);
        white-space: nowrap;
        letter-spacing: 0.2px;
        position: relative;
    }
    .nav-icon-btn:hover {
        background: rgba(0,230,118,0.10);
        border-color: rgba(0,230,118,0.40);
        color: var(--brand) !important;
        box-shadow: 0 0 12px rgba(0,230,118,0.18);
        transform: translateY(-1px);
    }
    .nav-icon-btn.btn-heart:hover {
        background: rgba(239,68,68,0.10);
        border-color: rgba(239,68,68,0.40);
        color: #ef4444 !important;
        box-shadow: 0 0 12px rgba(239,68,68,0.18);
    }
    .nav-icon-btn.btn-bell:hover {
        background: rgba(245,158,11,0.10);
        border-color: rgba(245,158,11,0.40);
        color: #f59e0b !important;
        box-shadow: 0 0 12px rgba(245,158,11,0.18);
    }

    /* ── User Dropdown Button ── */
    .btn-user-dropdown {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        background: linear-gradient(135deg, rgba(0,230,118,0.18) 0%, rgba(0,200,83,0.12) 100%);
        border: 1.5px solid rgba(0,230,118,0.40);
        border-radius: var(--r-xl);
        color: #fff !important;
        font-size: 0.80rem;
        font-weight: 700;
        padding: 0.4rem 1.2rem 0.4rem 0.8rem;
        text-decoration: none;
        transition: var(--ease);
        white-space: nowrap;
        cursor: pointer;
        letter-spacing: 0.2px;
        font-family: 'Inter', sans-serif;
    }
    .btn-user-dropdown:hover {
        background: linear-gradient(135deg, rgba(0,230,118,0.30) 0%, rgba(0,200,83,0.22) 100%);
        border-color: var(--brand);
        box-shadow: 0 0 20px rgba(0,230,118,0.28), 0 4px 16px rgba(0,0,0,0.3);
        transform: translateY(-1px);
    }
    .btn-user-avatar {
        width: 26px; height: 26px;
        border-radius: 50%;
        background: linear-gradient(135deg, var(--brand) 0%, var(--brand-dark) 100%);
        display: flex; align-items: center; justify-content: center;
        font-size: 0.72rem; font-weight: 800;
        color: #0a0a0a;
        flex-shrink: 0;
        box-shadow: 0 0 6px rgba(0,230,118,0.3);
    }
    .btn-user-chevron {
        font-size: 0.6rem;
        opacity: 0.7;
        transition: transform 0.25s ease;
    }
    .btn-user-dropdown.active .btn-user-chevron,
    .show > .btn-user-dropdown .btn-user-chevron { transform: rotate(180deg); }

    /* ── Dropdown Menu ── */
    .dropdown-menu-dark-custom {
        background: rgba(10,13,22,0.98) !important;
        backdrop-filter: blur(20px) !important;
        border: 1px solid rgba(0,230,118,0.15) !important;
        border-radius: 18px !important;
        min-width: 200px;
        overflow: hidden;
        box-shadow: 0 20px 60px rgba(0,0,0,0.6), 0 0 0 1px rgba(0,230,118,0.08) !important;
        padding: 6px !important;
        margin-top: 8px !important;
        animation: dropdownFadeIn 0.22s cubic-bezier(0.16,1,0.3,1) both;
    }
    @keyframes dropdownFadeIn {
        from { opacity: 0; transform: translateY(-8px) scale(0.96); }
        to   { opacity: 1; transform: translateY(0)    scale(1); }
    }
    .dropdown-item-custom {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 9px 12px;
        border-radius: 12px;
        font-size: 0.83rem;
        font-weight: 600;
        color: var(--white-80) !important;
        text-decoration: none;
        transition: var(--ease);
        cursor: pointer;
    }
    .dropdown-item-custom:hover {
        background: rgba(255,255,255,0.06) !important;
        color: #fff !important;
        padding-left: 16px;
    }
    .dropdown-item-custom .item-icon {
        width: 30px; height: 30px;
        border-radius: 8px;
        display: flex; align-items: center; justify-content: center;
        font-size: 0.75rem;
        flex-shrink: 0;
    }
    .dropdown-item-custom.danger { color: #ef4444 !important; }
    .dropdown-item-custom.danger:hover { background: rgba(239,68,68,0.10) !important; color: #ef4444 !important; }
    .dropdown-divider-custom {
        margin: 4px 0;
        border-color: rgba(255,255,255,0.07) !important;
    }
    .dropdown-user-header {
        padding: 10px 12px 8px;
        border-bottom: 1px solid rgba(255,255,255,0.06);
        margin-bottom: 4px;
    }
    .dropdown-user-name {
        font-size: 0.84rem;
        font-weight: 700;
        color: #fff;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        max-width: 160px;
    }
    .dropdown-user-label {
        font-size: 0.70rem;
        color: var(--brand);
        font-weight: 600;
        letter-spacing: 0.5px;
    }

    /* ── Login Button (not logged in) ── */
    .btn-login {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        background: linear-gradient(135deg, var(--brand) 0%, var(--brand-dark) 100%);
        border: none;
        border-radius: var(--r-xl);
        color: #0a0a0a !important;
        font-size: 0.82rem;
        font-weight: 800;
        padding: 0.45rem 1.4rem;
        text-decoration: none;
        letter-spacing: 0.3px;
        font-family: 'Outfit', sans-serif;
        transition: var(--spring);
        box-shadow: 0 4px 16px rgba(0,230,118,0.35);
        cursor: pointer;
    }
    .btn-login:hover {
        background: linear-gradient(135deg, #2bff8e 0%, var(--brand) 100%);
        color: #0a0a0a !important;
        transform: translateY(-2px) scale(1.02);
        box-shadow: 0 8px 28px rgba(0,230,118,0.50);
    }

    /* ── Badge ── */
    .badge-sharp {
        border-radius: var(--r-xl);
        background: #ef4444 !important;
        font-size: 0.60rem;
        font-weight: 800;
        min-width: 17px; height: 17px;
        line-height: 1;
        display: inline-flex;
        align-items: center; justify-content: center;
        padding: 2px 5px;
    }
    .badge-danger-pulse {
        background: #ef4444 !important;
        animation: pulseBadge 1.5s ease-in-out infinite;
    }
    @keyframes pulseBadge {
        0%,100% { box-shadow: 0 0 0 0 rgba(239,68,68,0.6); }
        50%      { box-shadow: 0 0 0 5px rgba(239,68,68,0); }
    }

    /* ── Divider Line ── */
    .nav-divider {
        width: 1px; height: 22px;
        background: rgba(255,255,255,0.10);
        flex-shrink: 0;
    }

    /* ── Sidebar Toggle ── */
    .sidebar-toggle-btn {
        font-size: 1.1rem;
        color: var(--white-80) !important;
        transition: var(--ease);
        padding: 6px 10px;
        border-radius: 10px;
        background: var(--white-06);
        border: 1px solid var(--white-12) !important;
    }
    .sidebar-toggle-btn:hover {
        color: var(--brand) !important;
        background: var(--brand-subtle) !important;
        border-color: rgba(0,230,118,0.30) !important;
        transform: scale(1.05);
    }

    /* ── FORMS & CARDS (Global) ── */
    .btn-brand {
        background: linear-gradient(135deg, var(--brand) 0%, var(--brand-dark) 100%);
        color: #0a0a0a;
        border: none;
        font-weight: 700;
        font-size: 0.82rem;
        letter-spacing: 0.4px;
        border-radius: var(--r-xl);
        padding: 0.45rem 1.4rem;
        transition: var(--ease);
        box-shadow: 0 2px 14px rgba(0,230,118,0.3);
    }
    .btn-brand:hover {
        background: linear-gradient(135deg, var(--brand-dark) 0%, var(--brand-deep) 100%);
        color: #fff;
        transform: translateY(-1px);
        box-shadow: 0 5px 22px rgba(0,230,118,0.4);
    }
    .card-product {
        border: 1px solid var(--border) !important;
        border-radius: var(--r-lg) !important;
        transition: transform 0.3s ease, box-shadow 0.3s ease, border-color 0.3s ease;
        overflow: hidden;
        background: var(--bg-card);
    }
    .card-product:hover {
        transform: translateY(-10px);
        box-shadow: var(--shadow-lg) !important;
        border-color: rgba(0,230,118,0.35) !important;
    }
    .form-control, .form-select {
        border-radius: var(--r-sm) !important;
        border: 1.5px solid var(--border);
        font-size: 0.875rem;
        padding: 0.55rem 0.9rem;
        transition: var(--ease);
        color: var(--txt);
    }
    .form-control:focus, .form-select:focus {
        border-color: var(--brand) !important;
        box-shadow: 0 0 0 3px rgba(0,230,118,0.15) !important;
    }
    .alert { border-radius: var(--r-md) !important; border: none; font-weight: 500; font-size: 0.875rem; }
    .alert-success { background: #ecfdf5; color: #065f46; }
    .alert-danger  { background: #fef2f2; color: #991b1b; }
    .alert-info    { background: #eff6ff; color: #1d4ed8; }
    .table { font-size: 0.875rem; }
    .table thead th {
        font-weight: 700; font-size: 0.75rem;
        letter-spacing: 0.8px; text-transform: uppercase; vertical-align: middle;
    }
    .table-dark { background: #1a1a2e !important; }
    .table tbody tr { transition: background 0.15s; }
    .breadcrumb { font-size: 0.82rem; background: transparent; }
    .breadcrumb-item a { color: var(--brand); text-decoration: none; font-weight: 600; }
    .breadcrumb-item a:hover { text-decoration: underline; }
    .section-heading {
        font-size: 1.4rem; font-weight: 800; letter-spacing: -0.4px;
        color: var(--txt); display: flex; align-items: center; gap: 10px;
    }
    .section-heading::before {
        content: ''; display: inline-block;
        width: 5px; height: 24px;
        background: var(--brand); border-radius: 3px;
    }
    ::-webkit-scrollbar { width: 5px; height: 5px; }
    ::-webkit-scrollbar-track { background: transparent; }
    ::-webkit-scrollbar-thumb { background: #d1d5db; border-radius: 4px; }
    ::-webkit-scrollbar-thumb:hover { background: var(--brand); }
    .rounded-xl { border-radius: var(--r-xl) !important; }
    .rounded-lg { border-radius: var(--r-lg) !important; }
    .rounded-md { border-radius: var(--r-md) !important; }
    .text-tiny { font-size: 0.72rem; }
    .fw-900 { font-weight: 900 !important; }
    .shadow-brand { box-shadow: 0 4px 20px rgba(0,230,118,0.25) !important; }

    /* ── Notification Bell ── */
    .notif-bell-alert {
        color: #f59e0b !important;
        animation: bellShake 0.6s ease-in-out 0.3s both;
    }
    @keyframes bellShake {
        0%,100% { transform: rotate(0deg); }
        20%      { transform: rotate(-15deg); }
        40%      { transform: rotate(15deg); }
        60%      { transform: rotate(-8deg); }
        80%      { transform: rotate(8deg); }
    }

    /* ── LEFT SIDEBAR OFF-CANVAS ── */
    .sidebar-offcanvas {
        background-color: #080b12 !important;
        border-right: 1px solid rgba(0,230,118,0.20) !important;
        width: 290px !important;
        box-shadow: 16px 0 50px rgba(0,0,0,0.7) !important;
    }
    .sidebar-header {
        background: linear-gradient(180deg, #0d1117 0%, #080b12 100%);
        padding: 1.1rem 1.3rem;
        border-bottom: 1px solid rgba(0,230,118,0.12) !important;
    }
    .sidebar-group-title {
        font-size: 0.68rem;
        font-weight: 800;
        text-transform: uppercase;
        letter-spacing: 1.8px;
        color: rgba(255,255,255,0.35);
        padding: 0.4rem 1.4rem;
        margin-bottom: 0.3rem;
    }
    .sidebar-link {
        display: flex;
        align-items: center;
        gap: 11px;
        padding: 0.65rem 1.6rem;
        color: rgba(255,255,255,0.72) !important;
        text-decoration: none !important;
        font-size: 0.84rem;
        font-weight: 500;
        transition: var(--ease);
        border-radius: 0;
        position: relative;
    }
    .sidebar-link::before {
        content: '';
        position: absolute;
        left: 0; top: 0; bottom: 0;
        width: 0;
        background: var(--brand);
        transition: width 0.25s ease;
        border-radius: 0 2px 2px 0;
    }
    .sidebar-link i {
        width: 18px; text-align: center;
        font-size: 0.9rem;
        color: var(--brand);
        transition: transform 0.24s ease;
        flex-shrink: 0;
    }
    .sidebar-link:hover {
        background: rgba(0,230,118,0.07) !important;
        color: #fff !important;
        padding-left: 2rem;
    }
    .sidebar-link:hover::before { width: 3px; }
    .sidebar-link:hover i { transform: scale(1.15); color: #fff; }

    /* ── Scroll Reveal ── */
    .fade-in-up {
        opacity: 0;
        transform: translateY(30px);
        transition: opacity 0.8s cubic-bezier(0.16, 1, 0.3, 1), transform 0.8s cubic-bezier(0.16, 1, 0.3, 1);
    }
    .fade-in-up.visible { opacity: 1; transform: translateY(0); }

    /* ── Global Toast ── */
    #nf-global-toast {
        display: none;
        position: fixed;
        top: 1.2rem; right: 1.5rem;
        min-width: 320px; max-width: 420px;
        border-radius: 20px;
        padding: 1rem 1.3rem;
        z-index: 99999;
        box-shadow: 0 20px 60px rgba(0,0,0,0.55);
        animation: toastSlideIn 0.35s cubic-bezier(.34,1.56,.64,1) both;
        pointer-events: all;
    }
    #nf-global-toast.show { display: flex; }
    #nf-global-toast.toast-success {
        background: rgba(8,20,12,0.97);
        border: 1.5px solid rgba(0,230,118,0.35);
        backdrop-filter: blur(12px);
    }
    #nf-global-toast.toast-failed {
        background: rgba(20,8,8,0.97);
        border: 1.5px solid rgba(239,68,68,0.35);
        backdrop-filter: blur(12px);
    }
    @keyframes toastSlideIn {
        from { opacity: 0; transform: translateX(40px) scale(0.95); }
        to   { opacity: 1; transform: translateX(0)    scale(1); }
    }
    .toast-icon {
        flex-shrink: 0; width: 40px; height: 40px; border-radius: 12px;
        display: flex; align-items: center; justify-content: center;
        font-size: 1.1rem; margin-right: 12px;
    }
    .toast-success .toast-icon { background: rgba(0,230,118,0.12); color: var(--brand); }
    .toast-failed  .toast-icon { background: rgba(239,68,68,0.12); color: #ef4444; }
    .toast-body-wrap { flex: 1; }
    .toast-title { font-size: 0.85rem; font-weight: 800; margin-bottom: 3px; }
    .toast-success .toast-title { color: var(--brand); }
    .toast-failed  .toast-title { color: #ef4444; }
    .toast-msg { font-size: 0.78rem; color: rgba(255,255,255,0.55); line-height: 1.4; }
    .toast-close {
        flex-shrink: 0; background: none; border: none;
        color: rgba(255,255,255,0.3); font-size: 0.9rem;
        cursor: pointer; padding: 0 0 0 8px; line-height: 1; align-self: flex-start;
    }
    .toast-close:hover { color: rgba(255,255,255,0.7); }
    .toast-actions { margin-top: 10px; display: flex; gap: 8px; }
    .toast-btn-primary {
        font-size: 0.74rem; font-weight: 700; padding: 4px 12px;
        border-radius: 50px; text-decoration: none; border: none; cursor: pointer;
    }
    .toast-success .toast-btn-primary { background: var(--brand); color: #0a0a12; }
    .toast-failed  .toast-btn-primary { background: #ef4444; color: #fff; }
    .toast-btn-secondary {
        font-size: 0.74rem; font-weight: 600; padding: 4px 12px;
        border-radius: 50px; text-decoration: none;
        background: rgba(255,255,255,0.07); border: 1px solid rgba(255,255,255,0.10);
        color: rgba(255,255,255,0.55);
    }

    /* ── RESPONSIVE ── */
    @media (max-width: 991.98px) {
        .navbar-custom { min-height: 60px; }
        .brand-logo-wrap { width: 36px !important; height: 36px !important; }
        .brand-name-text { font-size: 1rem !important; letter-spacing: 1.2px !important; }
        .nav-icon-btn { padding: 0.35rem 0.75rem !important; font-size: 0.75rem !important; gap: 4px !important; }
        .btn-login { padding: 0.38rem 1rem !important; font-size: 0.78rem !important; }
        .search-inner { width: 100% !important; }
        .search-inner:focus-within { width: 100% !important; }
    }
    @media (min-width: 992px) and (max-width: 1200px) {
        .nav-icon-btn { padding: 0.38rem 0.7rem !important; font-size: 0.75rem !important; gap: 4px !important; }
        .nav-icon-btn-cart { padding: 0.38rem 0.75rem !important; font-size: 0.75rem !important; gap: 5px !important; }
        .btn-login { padding: 0.4rem 1rem !important; font-size: 0.78rem !important; }
    }
</style>
