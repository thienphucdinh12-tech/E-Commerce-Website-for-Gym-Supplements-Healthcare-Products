package controllers.admin;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import shopping.ArticleDAO;
import shopping.Article;
import user.UserDTO;

@WebServlet(name = "ArticleActionController", urlPatterns = {"/ArticleActionController"})
public class ArticleActionController extends HttpServlet {
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        UserDTO loginUser = (session != null) ? (UserDTO) session.getAttribute("LOGIN_USER") : null;
        if (loginUser == null || (!"AD".equals(loginUser.getRoleID()) && !"MAN".equals(loginUser.getRoleID()) && !"CSKH".equals(loginUser.getRoleID()))) {
            response.sendRedirect("admin_login.jsp");
            return;
        }

        String subAction = request.getParameter("subAction");
        ArticleDAO dao = new ArticleDAO();

        try {
            if ("add".equalsIgnoreCase(subAction)) {
                String title = request.getParameter("title");
                String summary = request.getParameter("summary");
                String content = request.getParameter("content");
                String imageUrl = request.getParameter("imageUrl");
                String authorName = request.getParameter("authorName");

                if (authorName == null || authorName.trim().isEmpty()) {
                    authorName = (loginUser.getFullName() != null) ? loginUser.getFullName() : "Quản trị viên";
                }
                String authorUsername = (loginUser.getUserID() != null) ? loginUser.getUserID() : "admin";

                Article a = new Article(0, title, summary, content, imageUrl, authorUsername, authorName, "PENDING", false, null, null);
                boolean success = dao.insertArticle(a);
                if (success) {
                    session.setAttribute("SUCCESS_MESSAGE", "Thêm bài viết mới thành công! Bài viết đang chờ duyệt.");
                } else {
                    session.setAttribute("ERROR_MESSAGE", "Thêm bài viết mới thất bại!");
                }

            } else if ("update".equalsIgnoreCase(subAction)) {
                int id = Integer.parseInt(request.getParameter("articleId"));
                String title = request.getParameter("title");
                String summary = request.getParameter("summary");
                String content = request.getParameter("content");
                String imageUrl = request.getParameter("imageUrl");
                String authorName = request.getParameter("authorName");

                Article a = dao.getArticleById(id);
                if (a != null) {
                    a.setTitle(title);
                    a.setSummary(summary);
                    a.setContent(content);
                    a.setImageUrl(imageUrl);
                    a.setAuthorName(authorName);
                    
                    boolean success = dao.updateArticle(a);
                    if (success) {
                        session.setAttribute("SUCCESS_MESSAGE", "Cập nhật bài viết thành công!");
                    } else {
                        session.setAttribute("ERROR_MESSAGE", "Cập nhật bài viết thất bại!");
                    }
                } else {
                    session.setAttribute("ERROR_MESSAGE", "Không tìm thấy bài viết cần cập nhật!");
                }

            } else if ("approve".equalsIgnoreCase(subAction)) {
                int id = Integer.parseInt(request.getParameter("articleId"));
                boolean success = dao.updateStatus(id, "APPROVED");
                if (success) {
                    session.setAttribute("SUCCESS_MESSAGE", "Đã duyệt bài viết thành công! Hiện bài viết đã có thể được xuất bản.");
                } else {
                    session.setAttribute("ERROR_MESSAGE", "Duyệt bài viết thất bại!");
                }

            } else if ("reject".equalsIgnoreCase(subAction)) {
                int id = Integer.parseInt(request.getParameter("articleId"));
                boolean success = dao.updateStatus(id, "REJECTED");
                if (success) {
                    session.setAttribute("SUCCESS_MESSAGE", "Đã từ chối bài viết! Trạng thái xuất bản đã được tự động tắt.");
                } else {
                    session.setAttribute("ERROR_MESSAGE", "Từ chối bài viết thất bại!");
                }

            } else if ("togglePublish".equalsIgnoreCase(subAction)) {
                int id = Integer.parseInt(request.getParameter("articleId"));
                boolean published = Boolean.parseBoolean(request.getParameter("published"));

                Article a = dao.getArticleById(id);
                if (a != null) {
                    if (published && !"APPROVED".equalsIgnoreCase(a.getStatus())) {
                        session.setAttribute("ERROR_MESSAGE", "Bài viết phải được phê duyệt (APPROVED) trước khi xuất bản lên website!");
                    } else {
                        boolean success = dao.togglePublish(id, published);
                        if (success) {
                            session.setAttribute("SUCCESS_MESSAGE", published ? "Đã xuất bản bài viết lên website!" : "Đã gỡ bài viết xuống khỏi website!");
                        } else {
                            session.setAttribute("ERROR_MESSAGE", "Cập nhật trạng thái xuất bản thất bại!");
                        }
                    }
                } else {
                    session.setAttribute("ERROR_MESSAGE", "Không tìm thấy bài viết!");
                }

            } else if ("delete".equalsIgnoreCase(subAction)) {
                int id = Integer.parseInt(request.getParameter("articleId"));
                boolean success = dao.deleteArticle(id);
                if (success) {
                    session.setAttribute("SUCCESS_MESSAGE", "Đã xóa bài viết thành công!");
                } else {
                    session.setAttribute("ERROR_MESSAGE", "Xóa bài viết thất bại!");
                }
            }
        } catch (Exception e) {
            log("Error at ArticleActionController: " + e.toString());
            session.setAttribute("ERROR_MESSAGE", "Lỗi xử lý bài viết: " + e.getMessage());
        }

        response.sendRedirect("MainController?action=ManageArticles");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
}
