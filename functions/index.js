const { onDocumentCreated, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

/**
 * 1. 댓글 생성 시 알림 로직
 * - 게시글 작성자에게 알림 전송
 * - 대댓글일 경우 원댓글 작성자에게 알림 전송
 */
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
      let targetUserId = postData.authorId; // 기본은 게시글 작성자
      let notificationTitle = "New Comment";
      let message = `left a comment: "${content}"`;

      // 대댓글인 경우 원댓글 작성자를 타겟으로 설정
      if (parentId) {
        const parentSnap = await postRef.collection("comments").doc(parentId).get();
        if (parentSnap.exists) {
          targetUserId = parentSnap.data().authorId;
          notificationTitle = "New Reply";
          message = `replied to your comment: "${content}"`;
        }
      }

      // 자기 자신에게는 알림을 보내지 않음
      if (targetUserId === senderId) return;

      // Firestore 알림 문서 생성
      const notifRef = db.collection("artifacts").doc(appId).collection("users").doc(targetUserId).collection("notifications").doc();
      await notifRef.set({
        targetUserId, senderId, senderName, postId,
        postTitle: postData.title || "your post",
        message, type: "comment", createdAt: FieldValue.serverTimestamp(), isRead: false,
      });

      // FCM 푸시 발송
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

/**
 * 2. 댓글 좋아요 알림 로직
 * - 댓글에 좋아요가 추가되면 댓글 작성자에게 알림 전송
 */
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

      // 좋아요 개수가 늘어난 경우에만 실행
      if (newLikes.length <= oldLikes.length) return;

      const senderId = newLikes.find(id => !oldLikes.includes(id));
      if (!senderId) return;

      const targetUserId = afterData.authorId;
      if (targetUserId === senderId) return;

      const db = getFirestore();
      const senderDoc = await db.collection("artifacts").doc(appId).collection("users").doc(senderId).get();
      const senderName = senderDoc.data()?.displayName || "Someone";

      // 알림 문서 기록
      const notifRef = db.collection("artifacts").doc(appId).collection("users").doc(targetUserId).collection("notifications").doc();
      await notifRef.set({
        targetUserId, senderId, senderName, postId,
        message: `liked your comment: "${afterData.content}"`,
        type: "like", createdAt: FieldValue.serverTimestamp(), isRead: false,
      });

      // FCM 푸시 알림
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

/**
 * 3. 공지사항 생성 시 토픽 푸시 발송 (방식 B)
 * - 'notices' 토픽을 구독 중인 모든 기기에 알림 전송
 */
exports.onNoticeCreated = onDocumentCreated(
  "notices/{noticeId}",
  async (event) => {
    try {
      const noticeData = event.data.data();
      if (!noticeData) return;

      const title = noticeData.title || "New Announcement";
      const content = noticeData.content || "A new notice has been posted.";

      await getMessaging().send({
        topic: "notices",
        notification: {
          title: `[Notice] ${title}`,
          body: content.length > 100 ? content.substring(0, 97) + "..." : content,
        },
        apns: {
          payload: {
            aps: { sound: "default", badge: 1 },
          },
        },
        data: {
          type: "notice",
          noticeId: event.params.noticeId,
        },
      });

      console.log(`Notice push notification sent for: ${event.params.noticeId}`);
    } catch (error) {
      console.error("Error in onNoticeCreated:", error);
    }
  }
);

/**
 * 4. 신고 접수 시 자동 삭제 로직
 * - 한 게시글에 신고가 4회 누적되면 게시글을 자동으로 삭제하고 작성자에게 통보
 */
exports.onReportCreated = onDocumentCreated(
  "artifacts/{appId}/public/data/reports/{reportId}",
  async (event) => {
    try {
      const { appId, reportId } = event.params;
      const reportData = event.data.data();
      if (!reportData) return;

      const { targetId, targetType, reportedUserId } = reportData;

      // 게시글(post) 신고인 경우에만 누적 횟수 체크
      if (targetType !== "post") return;

      const db = getFirestore();
      const reportsRef = db.collection("artifacts").doc(appId).collection("public").doc("data").collection("reports");

      const snapshot = await reportsRef.where("targetId", "==", targetId).get();
      const reportCount = snapshot.size;

      console.log(`Post ${targetId} has ${reportCount} reports.`);

      // 임계값 4회 이상 시 삭제 처리
      if (reportCount >= 4) {
        const postRef = db.collection("artifacts").doc(appId).collection("public").doc("data").collection("posts").doc(targetId);
        const postSnap = await postRef.get();

        if (postSnap.exists) {
          const postTitle = postSnap.data().title || "your post";

          // 게시글 삭제
          await postRef.delete();
          console.log(`Post ${targetId} deleted due to accumulated reports (${reportCount}).`);

          // 작성자에게 시스템 알림 및 푸시 전송
          if (reportedUserId) {
            const notifRef = db.collection("artifacts").doc(appId).collection("users").doc(reportedUserId).collection("notifications").doc();
            await notifRef.set({
              targetUserId: reportedUserId,
              senderId: "system",
              senderName: "System",
              postId: targetId,
              postTitle: postTitle,
              message: "Your post has been removed due to multiple reports.",
              type: "system",
              createdAt: FieldValue.serverTimestamp(),
              isRead: false,
            });

            const userDoc = await db.collection("artifacts").doc(appId).collection("users").doc(reportedUserId).get();
            const token = userDoc.data()?.fcmToken;
            if (token) {
              await getMessaging().send({
                token,
                notification: {
                  title: "Post Removed",
                  body: "Your post was removed due to community reports.",
                },
                data: { type: "system_alert" },
              });
            }
          }
        }
      }
    } catch (error) {
      console.error("Error in onReportCreated:", error);
    }
  }
);