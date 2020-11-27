const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// Function to perform when FeedItem is created
exports.onCreateActivityFeedItem = functions.firestore
    .document('/feed/{userId}/feedItems/{activityFeedItem}')
.onCreate(async (snapshot, context) =>
{
    const userId = context.params.userId;
    const userRef = admin.firestore().doc(`users/${userId}`);
    const doc = await userRef.get();


    const androidNotificationToken = doc.data().androidNotificationToken;
    const createActivityFeedItem = snapshot.data();

    if(androidNotificationToken)
    {
        sendNotification(androidNotificationToken, createActivityFeedItem);
    }
    else
    {
        console.log("No token for user, can not send notification.")
    }

    function sendNotification(androidNotificationToken, activityFeedItem)
    {
        let body;

        switch (activityFeedItem.type)
        {
            case "comment":
                body = `${activityFeedItem.username} replied: ${activityFeedItem.commentData}`;
                break;

            case "like":
                body = `${activityFeedItem.username} liked your post`;
                break;

            case "follow":
                body = `${activityFeedItem.username} started following you`;
                break;

            default:
            break;
        }

        const message =
        {
            notification: { body },
            token: androidNotificationToken,
            data: { recipient: userId },
        };

        admin.messaging().send(message)
        .then(response =>
        {
            console.log("Successfully sent message", response);
        })
        .catch(error =>
        {
            console.log("Error sending message", error);
        })

    }
});

// Function to perform when Follower is created
exports.onCreateFollower = functions.firestore
  .document("/followers/{userId}/userFollowers/{followerId}")
  .onCreate(async (snapshot, context) => {

    console.log("Follower Created", snapshot.id);

    const userId = context.params.userId;

    const followerId = context.params.followerId;

    // Create timeline for posts with followed users
    const followedUserPostsRef = admin
      .firestore()
      .collection("posts")
      .doc(userId)
      .collection("usersPosts");

    // Create timeline for memory with followed user
    const followedUserMemoryRef = admin
       .firestore()
       .collection("memory")
       .doc(userId)
       .collection("usersMemory");

    const timelinePostsRef = admin
      .firestore()
      .collection("timeline")
      .doc(followerId)
      .collection("timelinePosts");

    const timelineMemoryRef = admin
       .firestore()
       .collection("timeline")
       .doc(followerId)
       .collection("timelineMemory");

    const querySnapshot = await followedUserPostsRef.get();

    querySnapshot.forEach(doc => {
      if (doc.exists) {
        const postId = doc.id;
        const postData = doc.data();
        timelinePostsRef.doc(postId).set(postData);
      }
    });

    const queryMemorySnapshot = await followedUserMemoryRef.get();

    queryMemorySnapshot.forEach(doc => {
      if (doc.exists) {
         const memoryId = doc.id;
         const memoryData = doc.data();
         timelineMemoryRef.doc(memoryId).set(memoryData);
       }
     });
  });


// Function to perform when Follower is deleted
  exports.onDeleteFollower = functions.firestore
  .document("/followers/{userId}/userFollowers/{followerId}")
  .onDelete(async (snapshot, context) => {

    console.log("Follower Deleted", snapshot.id);

    const userId = context.params.userId;

    const followerId = context.params.followerId;

    // Delete timeline posts for unfollowed user
    const timelinePostsRef = admin
      .firestore()
      .collection("timeline")
      .doc(followerId)
      .collection("timelinePosts")
      .where("ownerId", "==", userId);

    const querySnapshot = await timelinePostsRef.get();
    querySnapshot.forEach(doc => {
      if (doc.exists)
      {
        doc.ref.delete();
      }
    });

    // Delete timeline Memory for unfollowed user
    const timelineMemoryRef = admin
      .firestore()
      .collection("timeline")
      .doc(followerId)
      .collection("timelineMemory")
      .where("ownerId", "==", userId);

    const queryMemorySnapshot = await timelineMemoryRef.get();
    queryMemorySnapshot.forEach(doc => {
       if (doc.exists)
       {
         doc.ref.delete();
       }
     });

  });

// Function to perform when Post is created
exports.onCreatePost = functions.firestore
  .document("/posts/{userId}/usersPosts/{postId}")
  .onCreate(async (snapshot, context) => {

    const postCreated = snapshot.data();

    const userId = context.params.userId;

    const postId = context.params.postId;

    const userFollowersRef = admin
      .firestore()
      .collection("followers")
      .doc(userId)
      .collection("userFollowers");

    const querySnapshot = await userFollowersRef.get();

    querySnapshot.forEach(doc => {
      const followerId = doc.id;

    // for timeline posts
      admin
        .firestore()
        .collection("timeline")
        .doc(followerId)
        .collection("timelinePosts")
        .doc(postId)
        .set(postCreated);
    });
  });

// Function to perform when Post is updated
exports.onUpdatePost = functions.firestore
  .document("/posts/{userId}/usersPosts/{postId}")
  .onUpdate(async (change, context) => {
    const postUpdated = change.after.data();
    const userId = context.params.userId;
    const postId = context.params.postId;

    const userFollowersRef = admin
      .firestore()
      .collection("followers")
      .doc(userId)
      .collection("userFollowers");

    const querySnapshot = await userFollowersRef.get();

    querySnapshot.forEach(doc => {
      const followerId = doc.id;

      admin
        .firestore()
        .collection("timeline")
        .doc(followerId)
        .collection("timelinePosts")
        .doc(postId)
        .get()
        .then(doc => {
          if (doc.exists) {
            doc.ref.update(postUpdated);
          }
        });
    });
  });

// Function to perform when Post is deleted
exports.onDeletePost = functions.firestore
  .document("/posts/{userId}/usersPosts/{postId}")
  .onDelete(async (snapshot, context) => {
    const userId = context.params.userId;
    const postId = context.params.postId;

    const userFollowersRef = admin
      .firestore()
      .collection("followers")
      .doc(userId)
      .collection("userFollowers");

    const querySnapshot = await userFollowersRef.get();

    querySnapshot.forEach(doc => {
      const followerId = doc.id;

      admin
        .firestore()
        .collection("timeline")
        .doc(followerId)
        .collection("timelinePosts")
        .doc(postId)
        .get()
        .then(doc => {
          if (doc.exists) {
            doc.ref.delete();
          }
        });
    });
  });

// Functions to perform when memory is created
//exports.onCreateMemory = functions.firestore
//  .document("/memory/{userId}/usersMemory/{memoryId}")
//  .onCreate(async (snapshot, context) => {
//
//    const memoryCreated = snapshot.data();
//
//    const userId = context.params.userId;
//
//    const memoryId = context.params.memoryId;
//
//    const userFollowersRef = admin
//      .firestore()
//      .collection("followers")
//      .doc(userId)
//      .collection("userFollowers");
//
//    const queryMemorySnapshot = await userFollowersRef.get();
//
//    queryMemorySnapshot.forEach(doc => {
//      const followerId = doc.id;
//
//    // for timeline posts
//      admin
//        .firestore()
//        .collection("timeline")
//        .doc(followerId)
//        .collection("timelineMemory")
//        .doc(memoryId)
//        .set(memoryCreated);
//    });
//  });


// Functions to perform when memory is created
exports.onCreateMemory = functions.firestore
  .document("/memory/{userId}/users/{subUserId}/usersMemory/{memoryId}")
  .onCreate(async (snapshot, context) => {

    const memoryCreated = snapshot.data();

    const userId = context.params.userId;
    const subUserId = context.params.subUserId;
    const memoryId = context.params.memoryId;

    const userFollowersRef = admin
      .firestore()
      .collection("followers")
      .doc(userId)
      .collection("userFollowers");

    const queryMemorySnapshot = await userFollowersRef.get();

    queryMemorySnapshot.forEach(doc => {
      const followerId = doc.id;

    // for timeline posts
      admin
        .firestore()
        .collection("timeline")
        .doc(followerId)
        .collection("timelineMemory")
        .doc(memoryId)
        .set(memoryCreated);
    });
  });

// Function to perform when memory is updated
exports.onUpdateMemory = functions.firestore
  .document("/memory/{userId}/users/{subUserId}/usersMemory/{memoryId}")
  .onUpdate(async (change, context) => {
    const memoryUpdated = change.after.data();
    const userId = context.params.userId;
    const subUserId = context.params.subUserId;
    const memoryId = context.params.memoryId;

    const userFollowersRef = admin
      .firestore()
      .collection("followers")
      .doc(userId)
      .collection("userFollowers");

    const queryMemoryUpdateSnapshot = await userFollowersRef.get();

    queryMemoryUpdateSnapshot.forEach(doc => {
      const followerId = doc.id;

      admin
        .firestore()
        .collection("timeline")
        .doc(followerId)
        .collection("timelineMemory")
        .doc(memoryId)
        .get()
        .then(doc => {
          if (doc.exists) {
            doc.ref.update(memoryUpdated);
          }
        });
    });
  });

// Function to perform when Memory is deleted
exports.onDeleteMemory = functions.firestore
  .document("/memory/{userId}/users/{subUserId}/usersMemory/{memoryId}")
  .onDelete(async (snapshot, context) => {
    const userId = context.params.userId;
    const subUserId = context.params.subUserId;
    const memoryId = context.params.memoryId;

    const userFollowersRef = admin
      .firestore()
      .collection("followers")
      .doc(userId)
      .collection("userFollowers");

    const queryMemoryDeleteSnapshot = await userFollowersRef.get();

    queryMemoryDeleteSnapshot.forEach(doc => {
      const followerId = doc.id;

      admin
        .firestore()
        .collection("timeline")
        .doc(followerId)
        .collection("timelineMemory")
        .doc(memoryId)
        .get()
        .then(doc => {
          if (doc.exists) {
            doc.ref.delete();
          }
        });
    });
  });
