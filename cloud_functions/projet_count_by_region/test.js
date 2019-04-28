/**
 * Copyright 2016 Google Inc. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
const functions = require('firebase-functions');
const admin = require('firebase-admin');  
const config = functions.config();

admin.initializeApp(config.firebase);


functions.auth.user().onCreate(event => {
  const user = event.data;
  const userRef = admin.database().ref('/users').child(user.uid);

  return userRef.update(user);
});

exports.createUser = functions.firestore
    .document('users/{userId}')
    .onCreate((snap, context) => {
      // Get an object representing the document
      // e.g. {'name': 'Marie', 'age': 66}
      const newValue = snap.data();

      // access a particular field as you would any JS property
      const name = newValue.name+"-Test";
      

      // perform desired operations ...
    });


// // Keeps track of the length of the 'likes' child list in a separate property.
// exports.countlikechange = functions.database.ref('/activites/etakara/editions/{editionid}/projets/{projetid}').onWrite(
//     async (change) => {
//       const collectionRef = change.after.ref.parent;
//       const countRef = collectionRef.parent.child('regions');

//       let increment;
//       if (change.after.exists() && !change.before.exists()) {
//         increment = 1;
//       } else if (!change.after.exists() && change.before.exists()) {
//         increment = -1;
//       } else {
//         return null;
//       }

//       // Return the promise from countRef.transaction() so our function
//       // waits for this async event to complete before it exits.
//       await countRef.transaction((current) => {
//         return (current || 0) + increment;
//       });
//       console.log('Counter updated.');
//       return null;
//     });

// // If the number of likes gets deleted, recount the number of likes
// exports.recountlikes = functions.database.ref('/posts/{postid}/likes_count').onDelete(async (snap) => {
//   const counterRef = snap.ref;
//   const collectionRef = counterRef.parent.child('likes');

//   // Return the promise from counterRef.set() so our function
//   // waits for this async event to complete before it exits.
//   const messagesData = await collectionRef.once('value');
//   return await counterRef.set(messagesData.numChildren());
// });