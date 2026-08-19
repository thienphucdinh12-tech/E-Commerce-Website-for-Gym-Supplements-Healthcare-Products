package filters;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * UrlSecurityFilter — Maps clean/pretty URLs to internal servlets/JSPs
 * and protects direct browser access to raw .jsp files and servlet classes.
 */
@WebFilter(filterName = "UrlSecurityFilter", urlPatterns = {"/*"}, dispatcherTypes = {DispatcherType.REQUEST})
public class UrlSecurityFilter implements Filter {

    private static final Map<String, String> CLEAN_URL_MAP = new HashMap<>();
    private static final Map<String, String> JSP_REDIRECT_MAP = new HashMap<>();

    static {
        // Clean URL -> Internal target mapping
        CLEAN_URL_MAP.put("/cua-hang",    "/MainController");
        CLEAN_URL_MAP.put("/trang-chu",   "/MainController");
        CLEAN_URL_MAP.put("/gio-hang",    "/viewCart.jsp");
        CLEAN_URL_MAP.put("/thanh-toan",  "/OrderConfirmController");
        CLEAN_URL_MAP.put("/don-hang",    "/OrderHistoryController");
        CLEAN_URL_MAP.put("/dang-xuat",   "/LogoutController");
        CLEAN_URL_MAP.put("/ca-nhan",     "/ProfileController");
        CLEAN_URL_MAP.put("/yeu-thich",   "/ViewFavoriteController");
        CLEAN_URL_MAP.put("/thong-bao",   "/NotificationController");
        CLEAN_URL_MAP.put("/bai-viet",    "/BlogController");
        CLEAN_URL_MAP.put("/san-pham",    "/DetailController");
        CLEAN_URL_MAP.put("/nutriboost",  "/nutriboost.jsp");
        CLEAN_URL_MAP.put("/tim-kiem-goi-y", "/SearchAjaxController");
        CLEAN_URL_MAP.put("/gui-ma-xac-thuc", "/SendCodeAjaxController");

        // Direct .jsp access -> Clean URL redirect mapping
        JSP_REDIRECT_MAP.put("/login.jsp",        "/dang-nhap");
        JSP_REDIRECT_MAP.put("/register.jsp",     "/dang-ky");
        JSP_REDIRECT_MAP.put("/viewCart.jsp",     "/gio-hang");
        JSP_REDIRECT_MAP.put("/orderConfirm.jsp", "/thanh-toan");
        JSP_REDIRECT_MAP.put("/orderHistory.jsp", "/don-hang");
        JSP_REDIRECT_MAP.put("/profile.jsp",      "/ca-nhan");
        JSP_REDIRECT_MAP.put("/favorites.jsp",    "/yeu-thich");
        JSP_REDIRECT_MAP.put("/notifications.jsp","/thong-bao");
        JSP_REDIRECT_MAP.put("/blog.jsp",         "/bai-viet");
        JSP_REDIRECT_MAP.put("/blogDetail.jsp",   "/bai-viet");
        JSP_REDIRECT_MAP.put("/shopping.jsp",     "/cua-hang");
        JSP_REDIRECT_MAP.put("/nutriboost.jsp",   "/nutriboost");
    }

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        if (!(request instanceof HttpServletRequest) || !(response instanceof HttpServletResponse)) {
            chain.doFilter(request, response);
            return;
        }

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String path = req.getRequestURI().substring(req.getContextPath().length());

        // 0. Safety Bypass for Admin panel, static resources, and internal assets
        String lowerPath = path.toLowerCase();
        if (lowerPath.contains("admin") 
                || lowerPath.contains("manage") 
                || lowerPath.contains("createuser") 
                || lowerPath.contains("dashboard") 
                || lowerPath.contains("batch") 
                || lowerPath.contains("ticket") 
                || lowerPath.contains("return") 
                || lowerPath.startsWith("/css/") 
                || lowerPath.startsWith("/js/") 
                || lowerPath.startsWith("/image/") 
                || lowerPath.startsWith("/fonts/") 
                || lowerPath.startsWith("/assets/")) {
            chain.doFilter(request, response);
            return;
        }

        // 1. Handle root path "/"
        if ("/".equals(path)) {
            req.getRequestDispatcher("/MainController?action=GoShopping").forward(req, resp);
            return;
        }

        // 2. Dynamic GET vs POST for login & register paths
        if ("/dang-nhap".equals(path)) {
            if ("POST".equalsIgnoreCase(req.getMethod())) {
                req.getRequestDispatcher("/LoginController").forward(req, resp);
            } else {
                req.getRequestDispatcher("/login.jsp").forward(req, resp);
            }
            return;
        }

        if ("/dang-ky".equals(path)) {
            if ("POST".equalsIgnoreCase(req.getMethod())) {
                req.getRequestDispatcher("/RegisterController").forward(req, resp);
            } else {
                req.getRequestDispatcher("/register.jsp").forward(req, resp);
            }
            return;
        }

        // 3. Handle clean URL mapping
        if (CLEAN_URL_MAP.containsKey(path)) {
            String internalTarget = CLEAN_URL_MAP.get(path);
            String queryString = req.getQueryString();
            if (queryString != null && !queryString.isEmpty()) {
                if (internalTarget.contains("?")) {
                    internalTarget += "&" + queryString;
                } else {
                    internalTarget += "?" + queryString;
                }
            }
            req.getRequestDispatcher(internalTarget).forward(req, resp);
            return;
        }

        // 4. Prevent direct access to raw .jsp files from browser
        if (path.endsWith(".jsp") && !path.startsWith("/includes/")) {
            String cleanRedirect = JSP_REDIRECT_MAP.get(path);
            if (cleanRedirect != null) {
                String queryString = req.getQueryString();
                if (queryString != null && !queryString.isEmpty()) {
                    cleanRedirect += "?" + queryString;
                }
                resp.sendRedirect(req.getContextPath() + cleanRedirect);
                return;
            } else {
                resp.sendRedirect(req.getContextPath() + "/cua-hang");
                return;
            }
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}
