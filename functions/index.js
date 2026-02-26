const { onDocumentCreated, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

// 1. 댓글 생성 알림 (기존 유지 및 대댓글 대응)
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
      const parentId = commentData.parentId;

      const db = getFirestore();
      const postRef = db.collection("artifacts").doc(appId).collection("public").doc("data").collection("posts").doc(postId);
      const postSnap = await postRef.get();
      if (!postSnap.exists) return;

      const postData = postSnap.data();
      let targetUserId = postData.authorId;
      let notificationTitle = "New Comment";
      let message = `left a comment: "${content}"`;

      if (parentId) {
        const parentSnap = await postRef.collection("comments").doc(parentId).get();
        if (parentSnap.exists) {
          targetUserId = parentSnap.data().authorId;
          notificationTitle = "New Reply";
          message = `replied to your comment: "${content}"`;
        }
      }

      if (targetUserId === senderId) return;

      const notifRef = db.collection("artifacts").doc(appId).collection("users").doc(targetUserId).collection("notifications").doc();
      await notifRef.set({
        targetUserId, senderId, senderName, postId, postTitle: postData.title || "your post",
        message, type: "comment", createdAt: FieldValue.serverTimestamp(), isRead: false,
      });

      const userDoc = await db.collection("artifacts").doc(appId).collection("users").doc(targetUserId).get();
      const token = userDoc.data()?.fcmToken;
      if (!token) return;

      await getMessaging().send({
        token,
        notification: { title: notificationTitle, body: `${senderName} ${message}` },
        data: { postId, type: "comment" },
      });
    } catch (error) {
      console.error("Error in onCommentCreated:", error);
    }
  }
);

// 2. [추가] 댓글 좋아요 알림
exports.onCommentLiked = onDocumentUpdated(
  "artifacts/{appId}/public/data/posts/{postId}/comments/{commentId}",
  async (event) => {
    try {
      const { appId, postId } = event.params;
      const beforeData = event.data.before.data();
      const afterData = event.data.after.data();

      if (!beforeData || !afterData) return;

      const oldLikes = beforeData.likes || [];
      const newLikes = afterData.likes || [];

      // 좋아요 수가 늘어난 경우에만 알림 발송
      if (newLikes.length <= oldLikes.length) return;

      // 새로 추가된 유저 ID 찾기
      const senderId = newLikes.find(id => !oldLikes.includes(id));
      if (!senderId) return;

      const targetUserId = afterData.authorId;
      // 본인이 본인 댓글에 좋아요를 누른 경우 제외
      if (targetUserId === senderId) return;

      const db = getFirestore();

      // 발신자 이름 조회를 위해 프로필 정보 확인 (또는 기본값 사용)
      // 여기서는 단순히 'Someone'으로 처리하거나 발신자 정보를 가져올 수 있습니다.
      const senderDoc = await db.collection("artifacts").doc(appId).collection("users").doc(senderId).get();
      const senderName = senderDoc.data()?.displayName || "Someone";

      const notifRef = db.collection("artifacts").doc(appId).collection("users").doc(targetUserId).collection("notifications").doc();
      await notifRef.set({
        targetUserId, senderId, senderName, postId,
        message: `liked your comment: "${afterData.content}"`,
        type: "like", createdAt: FieldValue.serverTimestamp(), isRead: false,
      });

      const userDoc = await db.collection("artifacts").doc(appId).collection("users").doc(targetUserId).get();
      const token = userDoc.data()?.fcmToken;
      if (!token) return;

      await getMessaging().send({
        token,
        notification: {
          title: "Comment Liked",
          body: `${senderName} liked your comment.`,
        },
        data: { postId, type: "comment_like" },
      });
    } catch (error) {
      console.error("Error in onCommentLiked:", error);
    }
  }
);