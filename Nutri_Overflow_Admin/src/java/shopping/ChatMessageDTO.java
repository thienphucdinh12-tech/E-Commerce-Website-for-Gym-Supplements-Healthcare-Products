package shopping;

import java.io.Serializable;
import java.sql.Timestamp;

public class ChatMessageDTO implements Serializable {
    private int messageId;
    private int sessionId;
    private String senderType;
    private String senderName;
    private String messageText;
    private Timestamp sentAt;

    public ChatMessageDTO() {
    }

    public ChatMessageDTO(int messageId, int sessionId, String senderType, String senderName, 
                          String messageText, Timestamp sentAt) {
        this.messageId = messageId;
        this.sessionId = sessionId;
        this.senderType = senderType;
        this.senderName = senderName;
        this.messageText = messageText;
        this.sentAt = sentAt;
    }

    public int getMessageId() {
        return messageId;
    }

    public void setMessageId(int messageId) {
        this.messageId = messageId;
    }

    public int getSessionId() {
        return sessionId;
    }

    public void setSessionId(int sessionId) {
        this.sessionId = sessionId;
    }

    public String getSenderType() {
        return senderType;
    }

    public void setSenderType(String senderType) {
        this.senderType = senderType;
    }

    public String getSenderName() {
        return senderName;
    }

    public void setSenderName(String senderName) {
        this.senderName = senderName;
    }

    public String getMessageText() {
        return messageText;
    }

    public void setMessageText(String messageText) {
        this.messageText = messageText;
    }

    public Timestamp getSentAt() {
        return sentAt;
    }

    public void setSentAt(Timestamp sentAt) {
        this.sentAt = sentAt;
    }
}
