package shopping;

import java.util.Date;

public class ReviewDTO {
    private int reviewId;
    private int productId;
    private int userId;
    private String fullName;
    private int rating;
    private String commentText;
    private Date createdAt;

    public ReviewDTO() {}

    public ReviewDTO(int reviewId, int productId, int userId, String fullName, int rating, String commentText, Date createdAt) {
        this.reviewId = reviewId;
        this.productId = productId;
        this.userId = userId;
        this.fullName = fullName;
        this.rating = rating;
        this.commentText = commentText;
        this.createdAt = createdAt;
    }

    public int getReviewId() { return reviewId; }
    public void setReviewId(int reviewId) { this.reviewId = reviewId; }

    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public int getRating() { return rating; }
    public void setRating(int rating) { this.rating = rating; }

    public String getCommentText() { return commentText; }
    public void setCommentText(String commentText) { this.commentText = commentText; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
}
