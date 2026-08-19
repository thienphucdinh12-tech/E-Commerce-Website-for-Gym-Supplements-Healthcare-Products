package VNpay;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Receives IPN (Instant Payment Notification) callbacks from VNPay servers.
 * VNPay calls this endpoint via POST after every payment attempt.
 * This servlet only updates the DB — it cannot touch the user's HTTP session
 * because the call comes from VNPay servers, not the user's browser.
 */
@WebServlet(name = "VNPayIPNServlet", urlPatterns = {"/VNPayIPNServlet"})
public class VNPayIPNServlet extends HttpServlet {

    private final VNPayService vnPayService = new VNPayService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Collect all query params from VNPay
        Map<String, String> params = new HashMap<>();
        request.getParameterMap().forEach((k, v) -> params.put(k, v[0]));

        // Process and reply to VNPay
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String result = vnPayService.processIPN(params);

        try (PrintWriter out = response.getWriter()) {
            out.print(result);
            out.flush();
        }
    }

    /** Some VNPay sandbox configs call GET — support both */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}
