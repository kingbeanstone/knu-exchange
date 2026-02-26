const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

exports.onCommentCreated = onDocumentCreated(
  "artifacts/{appId}/public/data/posts/{postId}/comments/{commentId}",
  async (event) => {
    try {
      const { appId, postId, commentId } = event.params;
      const commentData = event.data.data();

      if (!commentData) return;

      const senderId = commentData.authorId;
      const senderName = commentData.author;
      const content = commentData.content;
      const parentId = commentData.parentId; // [추가] 부모 댓글 ID 확인

      const db = getFirestore();

      // 1. 기본 정보 조회 (게시글 정보)
      const postRef = db
        .collection("artifacts")
        .doc(appId)
        .collection("public")
        .doc("data")
        .collection("posts")
        .doc(postId);

      const postSnap = await postRef.get();
      if (!postSnap.exists) return;

      const postData = postSnap.data();
      const postAuthorId = postData.authorId;
      const postTitle = postData.title || "your post";

      let targetUserId = postAuthorId;
      let notificationMessage = `left a comment: "${content}"`;
      let notificationTitle = "New Comment";

      // 2. [대댓글 로직] parentId가 있으면 알림 대상을 댓글 작성자로 변경
      if (parentId) {
        const parentCommentSnap = await postRef.collection("comments").doc(parentId).get();
        if (parentCommentSnap.exists) {
          targetUserId = parentCommentSnap.data().authorId;
          notificationMessage = `replied to your comment: "${content}"`;
          notificationTitle = "New Reply";
        }
      }

      // 본인이 본인 글/댓글에 반응한 경우 알림 미발송
      if (targetUserId === senderId) return;

      // 3. 알림 문서 생성
      const notifRef = db
        .collection("artifacts")
        .doc(appId)
        .collection("users")
        .doc(targetUserId)
        .collection("notifications")
        .doc();

      await notifRef.set({
        targetUserId,
        senderId,
        senderName,
        postId,
        postTitle,
        message: notificationMessage,
        type: "comment",
        createdAt: FieldValue.serverTimestamp(),
        isRead: false,
      });

      // 4. FCM 푸시 발송
      const userDoc = await db
        .collection("artifacts")
        .doc(appId)
        .collection("users")
        .doc(targetUserId)
        .get();

      const token = userDoc.data()?.fcmToken;
      if (!token) return;

      await getMessaging().send({
        token,
        notification: {
          title: notificationTitle,
          body: `${senderName} ${notificationMessage.replace(content, '"' + content + '"')}`,
        },
        data: {
          postId,
          type: "comment",
        },
      });

    } catch (error) {
      console.error("Error sending comment notification:", error);
    }
  }
);