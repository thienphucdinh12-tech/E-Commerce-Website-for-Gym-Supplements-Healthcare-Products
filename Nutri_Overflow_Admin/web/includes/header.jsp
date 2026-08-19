<%@page contentType="text/html" pageEncoding="UTF-8"%>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
<style>
    /* =============================================
       NUTRIOVERFLOW — GLOBAL DESIGN SYSTEM
       Theme: Dark Gym + Neon Green Accent
    ============================================= */
    :root {
        --brand:        #00e676;
        --brand-dark:   #00c853;
        --brand-deep:   #009624;
        --bg-page:      #f0f2f5;
        --bg-card:      #ffffff;
        --txt:          #111827;
        --txt-muted:    #6b7280;
        --border:       #e5e7eb;
        --shadow-sm:    0 1px 4px rgba(0,0,0,0.07);
        --shadow-md:    0 4px 18px rgba(0,0,0,0.10);
        --shadow-lg:    0 12px 40px rgba(0,0,0,0.15);
        --r-sm: 8px; --r-md: 14px; --r-lg: 20px; --r-xl: 50px;
        --ease: all 0.25s ease;
    }
    *, *::before, *::after { box-sizing: border-box; }

    body {
        font-family: 'Inter', sans-serif;
        background: var(--bg-page);
        color: var(--txt);
        font-size: 0.92rem;
        line-height: 1.65;
    }

    /* ── BRAND COLOR ── */
    .text-brand { color: var(--brand) !important; }

    /* ── NAVBAR ── */
    .navbar-custom {
        background: rgba(10, 10, 18, 0.97) !important;
        backdrop-filter: blur(14px);
        -webkit-backdrop-filter: blur(14px);
        border-bottom: 2px solid rgba(0,230,118,0.45);
        padding: 0.65rem 0;
    }
    .navbar-brand-text {
        font-weight: 900;
        font-size: 1.15rem;
        letter-spacing: 2px;
        text-transform: uppercase;
        color: var(--brand) !important;
    }
    .nav-link {
        font-weight: 600;
        font-size: 0.8rem;
        letter-spacing: 1px;
        text-transform: uppercase;
        color: rgba(255,255,255,0.8) !important;
        padding: 0.35rem 0 !important;
        position: relative;
        transition: color 0.2s;
    }
    .nav-link:hover { color: var(--brand) !important; }
    .nav-link::after {
        content: '';
        position: absolute;
        bottom: 0; left: 0;
        width: 0; height: 2px;
        background: var(--brand);
        border-radius: 2px;
        transition: width 0.3s ease;
    }
    .nav-link:hover::after { width: 100%; }

    /* ── SEARCH INPUT ── */
    .search-input {
        background: rgba(255,255,255,0.09) !important;
        border: 1px solid rgba(255,255,255,0.18) !important;
        border-radius: var(--r-xl) !important;
        color: #fff !important;
        font-size: 0.84rem;
        padding: 0.42rem 1.1rem !important;
        width: 230px;
        transition: var(--ease);
    }
    .search-input::placeholder { color: rgba(255,255,255,0.4) !important; opacity: 1; }
    .search-input:focus {
        border-color: var(--brand) !important;
        box-shadow: 0 0 0 3px rgba(0,230,118,0.2) !important;
        background: rgba(0,0,0,0.45) !important;
        width: 270px;
        outline: none;
    }
    .search-btn {
        background: var(--brand);
        border: none;
        border-radius: var(--r-xl) !important;
        color: #0a0a0a;
        font-weight: 700;
        padding: 0.42rem 0.95rem;
        transition: var(--ease);
        margin-left: 6px;
    }
    .search-btn:hover { background: var(--brand-dark); color: #fff; transform: scale(1.05); }

    /* Search dropdown */
    #searchResult, #searchResultMobile {
        position: absolute;
        z-index: 1055;
        width: 100%;
        top: calc(100% + 8px);
        background: #fff;
        border-radius: var(--r-md);
        box-shadow: var(--shadow-lg);
        overflow: hidden;
        border: 1px solid var(--border);
    }

    /* ── NAVBAR ICON BUTTONS ── */
    .nav-icon-btn {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        background: rgba(255,255,255,0.07);
        border: 1px solid rgba(255,255,255,0.14);
        border-radius: var(--r-xl);
        color: rgba(255,255,255,0.85) !important;
        font-size: 0.8rem;
        font-weight: 600;
        padding: 0.4rem 1rem;
        text-decoration: none;
        transition: var(--ease);
        white-space: nowrap;
    }
    .nav-icon-btn:hover {
        background: rgba(0,230,118,0.13);
        border-color: var(--brand);
        color: var(--brand) !important;
    }
    .nav-icon-btn.btn-heart:hover {
        background: rgba(239,68,68,0.13);
        border-color: #ef4444;
        color: #ef4444 !important;
    }

    /* ── PRIMARY BUTTON ── */
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

    /* ── PRODUCT CARDS ── */
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

    /* ── FORM CONTROLS ── */
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

    /* ── ALERTS ── */
    .alert {
        border-radius: var(--r-md) !important;
        border: none;
        font-weight: 500;
        font-size: 0.875rem;
    }
    .alert-success { background: #ecfdf5; color: #065f46; }
    .alert-danger  { background: #fef2f2; color: #991b1b; }
    .alert-info    { background: #eff6ff; color: #1d4ed8; }

    /* ── TABLES ── */
    .table { font-size: 0.875rem; }
    .table thead th {
        font-weight: 700;
        font-size: 0.75rem;
        letter-spacing: 0.8px;
        text-transform: uppercase;
        vertical-align: middle;
    }
    .table-dark { background: #1a1a2e !important; }
    .table tbody tr { transition: background 0.15s; }

    /* ── BREADCRUMB ── */
    .breadcrumb { font-size: 0.82rem; background: transparent; }
    .breadcrumb-item a { color: var(--brand); text-decoration: none; font-weight: 600; }
    .breadcrumb-item a:hover { text-decoration: underline; }

    /* ── BADGE ── */
    .badge-sharp {
        border-radius: var(--r-xl);
        background: #ef4444 !important;
        font-size: 0.62rem;
        font-weight: 700;
        min-width: 17px;
        height: 17px;
        line-height: 1;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        padding: 2px 5px;
    }

    /* ── SECTION HEADING ── */
    .section-heading {
        font-size: 1.4rem;
        font-weight: 800;
        letter-spacing: -0.4px;
        color: var(--txt);
        display: flex;
        align-items: center;
        gap: 10px;
    }
    .section-heading::before {
        content: '';
        display: inline-block;
        width: 5px; height: 24px;
        background: var(--brand);
        border-radius: 3px;
    }

    /* ── SCROLLBAR ── */
    ::-webkit-scrollbar { width: 5px; height: 5px; }
    ::-webkit-scrollbar-track { background: transparent; }
    ::-webkit-scrollbar-thumb { background: #d1d5db; border-radius: 4px; }
    ::-webkit-scrollbar-thumb:hover { background: var(--brand); }

    /* ── UTILITY ── */
    .rounded-xl { border-radius: var(--r-xl) !important; }
    .rounded-lg { border-radius: var(--r-lg) !important; }
    .rounded-md { border-radius: var(--r-md) !important; }
    .text-tiny { font-size: 0.72rem; }
    .fw-900 { font-weight: 900 !important; }
    .shadow-brand { box-shadow: 0 4px 20px rgba(0,230,118,0.25) !important; }

    /* ── BRAND LOGO ── */
    .navbar-brand-logo {
        text-decoration: none;
        transition: all 0.3s ease;
    }
    .navbar-brand-logo:hover { opacity: 0.9; }
    .navbar-brand-logo:hover .brand-logo-wrap {
        box-shadow: 0 0 0 2px rgba(0,230,118,0.6), 0 0 18px rgba(0,230,118,0.35);
        transform: scale(1.06) rotate(-3deg);
    }
    .navbar-brand-logo:hover .brand-name-text {
        letter-spacing: 2.5px;
    }

    .brand-logo-wrap {
        width: 54px;
        height: 54px;
        border-radius: 50%;
        overflow: hidden;
        border: 2.5px solid rgba(0,230,118,0.65);
        box-shadow: 0 0 14px rgba(0,230,118,0.25);
        flex-shrink: 0;
        transition: all 0.3s ease;
    }
    .brand-logo-img {
        width: 100%;
        height: 100%;
        object-fit: cover;
        object-position: center center;
        /* Zoom in slightly to crop out the black border padding */
        transform: scale(1.25);
        display: block;
    }

    .brand-name-text {
        font-size: 1.25rem;
        font-weight: 800;
        letter-spacing: 2px;
        text-transform: uppercase;
        color: #ffffff;
        transition: letter-spacing 0.3s ease;
        line-height: 1;
    }
    .brand-name-accent {
        color: var(--brand);
    }

    /* ── RESPONSIVE MOBILE STYLES ── */
    @media (max-width: 991.98px) {
        .navbar-custom {
            padding: 0.4rem 0 !important;
        }
        .brand-logo-wrap {
            width: 38px !important;
            height: 38px !important;
            border-width: 1.5px !important;
            box-shadow: 0 0 8px rgba(0,230,118,0.2) !important;
        }
        .brand-logo-img {
            transform: scale(1.2) !important;
        }
        .brand-name-text {
            font-size: 1rem !important;
            letter-spacing: 1px !important;
        }
        .navbar-brand-logo:hover .brand-name-text {
            letter-spacing: 1.2px !important;
        }
        .nav-icon-btn {
            padding: 0.38rem 0.65rem !important;
            font-size: 0.76rem !important;
            gap: 4px !important;
        }
        .btn-brand {
            padding: 0.38rem 0.65rem !important;
            font-size: 0.76rem !important;
            min-width: 32px !important;
            height: 32px !important;
            display: inline-flex !important;
            align-items: center !important;
            justify-content: center !important;
            border-radius: var(--r-xl) !important;
        }
        .search-input {
            width: 100% !important;
        }
        .search-input:focus {
            width: 100% !important;
        }
    }

    /* ── CUSTOM PREMIUM DROPDOWN MENU STYLES ── */
    .dropdown-menu {
        border-radius: 12px !important;
        border: 1px solid #e5e7eb !important;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08) !important;
        padding: 0.5rem !important;
    }
    .dropdown-item {
        border-radius: 8px !important;
        padding: 0.5rem 1rem !important;
        font-size: 0.88rem !important;
        font-weight: 500 !important;
        color: #4b5563 !important;
        transition: all 0.15s ease !important;
    }
    .dropdown-item:hover {
        background-color: #f3f4f6 !important;
        color: #8b0000 !important;
    }
    .dropdown-item.active {
        background-color: #8b0000 !important;
        color: #ffffff !important;
    }
    
    /* ── OFFCANVAS SIDEBAR CUSTOM PREMIUM STYLES ── */
    .offcanvas {
        box-shadow: 0 0 40px rgba(0,0,0,0.15) !important;
    }
    .offcanvas-body .nav-link {
        font-weight: 600 !important;
        font-size: 0.88rem !important;
        text-transform: none !important;
        letter-spacing: 0.2px !important;
        color: #374151 !important;
        padding: 0.65rem 1rem !important;
        border-radius: 8px !important;
        transition: all 0.2s ease !important;
        display: flex !important;
        align-items: center !important;
    }
    .offcanvas-body .nav-link:hover {
        background-color: #f3f4f6 !important;
        color: #8b0000 !important;
    }
    .offcanvas-body .nav-link.active {
        background-color: #8b0000 !important;
        color: #ffffff !important;
        box-shadow: 0 4px 12px rgba(139, 0, 0, 0.2) !important;
    }
    .offcanvas-body .nav-link::after {
        display: none !important;
    }
</style>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        if (typeof bootstrap !== 'undefined') {
            var dropdownElementList = [].slice.call(document.querySelectorAll('.admin-tab-container .dropdown-toggle'));
            dropdownElementList.forEach(function (dropdownToggleEl) {
                new bootstrap.Dropdown(dropdownToggleEl, {
                    popperConfig: {
                        strategy: 'fixed'
                    }
                });
            });
        }
    });
</script>

