package shopping;

import java.sql.Timestamp;

public class Article {
    private int id;
    private String title;
    private String summary;
    private String content;
    private String imageUrl;
    private String authorUsername;
    private String authorName;
    private String status; // PENDING, APPROVED, REJECTED
    private boolean published; // is_published
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public Article() {}

    public Article(int id, String title, String summary, String content, String imageUrl, 
                   String authorUsername, String authorName, String status, boolean published, 
                   Timestamp createdAt, Timestamp updatedAt) {
        this.id = id;
        this.title = title;
        this.summary = summary;
        this.content = content;
        this.imageUrl = imageUrl;
        this.authorUsername = authorUsername;
        this.authorName = authorName;
        this.status = status;
        this.published = published;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getSummary() { return summary; }
    public void setSummary(String summary) { this.summary = summary; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public String getAuthorUsername() { return authorUsername; }
    public void setAuthorUsername(String authorUsername) { this.authorUsername = authorUsername; }

    public String getAuthorName() { return authorName; }
    public void setAuthorName(String authorName) { this.authorName = authorName; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public boolean isPublished() { return published; }
    public void setPublished(boolean published) { this.published = published; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}
